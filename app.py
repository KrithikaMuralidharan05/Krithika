import io
import re
import base64

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

import pandas as pd
from flask import Flask, render_template, request

app = Flask(__name__)

REQUIRED_COLUMNS = ["Date", "Type", "Category", "Amount"]

CHANNEL_PREFIXES = {
    "UPI", "NEFT CR", "NEFT DR", "IMPS", "ACH D", "ACH C", "ATM",
    "POS", "CHQS", "CHQ", "TRANSFER", "RTGS", "BY CLG", "BY CLEAR",
    "CHGS", "NACH", "AEPS", "MOBILE", "BAL", "NRI",
}

STOP_TOKENS = {
    "KKBK", "UTIB", "HDFC", "ICICI", "YESB", "PTYS", "OKAXIS",
    "AXIS", "IDIB", "SBI", "KARB", "MAIRTEL", "INDIANBANK", "PAYTM",
    "IDFB", "APL", "OKSBI", "UPI", "IMPS", "PAYMENT", "TRANSACTION",
    "NO REMARK", "PAYMENT FOR", "SALARY FOR", "YOU ARE PAYING FOR",
}

DATE_RE = re.compile(r"^\d{2}/\d{2}/\d{2}$")


def analyze_transactions(df):
    df = df.copy()
    df["Date"] = pd.to_datetime(df["Date"])
    df["Amount"] = pd.to_numeric(df["Amount"], errors="coerce")
    df = df.dropna(subset=["Amount"])

    total_credit = df.loc[df["Type"].str.lower() == "credit", "Amount"].sum()
    total_debit = df.loc[df["Type"].str.lower() == "debit", "Amount"].sum()
    net_balance = total_credit - total_debit

    summary = {
        "total_transactions": len(df),
        "total_credit": total_credit,
        "total_debit": total_debit,
        "net_balance": net_balance,
    }

    spending = (
        df.loc[df["Type"].str.lower() == "debit"]
        .groupby("Category")["Amount"]
        .sum()
        .sort_values(ascending=False)
    )
    top5 = spending.head(5).reset_index()
    top5.columns = ["Category", "Total Spent"]
    top5_table = top5.to_dict("records")

    income_categories = (
        df.loc[df["Type"].str.lower() == "credit"]
        .groupby("Category")["Amount"]
        .sum()
        .sort_values(ascending=False)
    )

    monthly = (
        df.assign(Month=df["Date"].dt.to_period("M").astype(str))
        .groupby(["Month", "Type"])["Amount"]
        .sum()
        .unstack(fill_value=0)
    )

    return df, summary, top5_table, spending, income_categories, monthly


PROFESSIONAL_PALETTE = [
    "#984ea3", "#e41a1c", "#4daf4a", "#ff7f00",
    "#377eb8", "#ffff33", "#a65628", "#f781bf",
    "#1b9e77", "#d95f02", "#7570b3", "#66a61e",
    "#e6ab02", "#bc80bd", "#80b1d3", "#999999",
]


def make_chart(data, title, kind="bar", cmap="viridis", is_series=False):
    plt.rcParams.update({
        "figure.facecolor": "#1e293b",
        "axes.facecolor": "#1e293b",
        "axes.edgecolor": "#334155",
        "axes.labelcolor": "#e2e8f0",
        "xtick.color": "#94a3b8",
        "ytick.color": "#94a3b8",
        "axes.titlecolor": "#f1f5f9",
    })
    fig, ax = plt.subplots(figsize=(9, 5))

    if kind == "pie":
        colors = [PROFESSIONAL_PALETTE[i % len(PROFESSIONAL_PALETTE)]
                  for i in range(len(data))]
        wedges, texts, autotexts = ax.pie(
            data.values,
            labels=[s[:22] for s in data.index],
            autopct="%1.1f%%",
            startangle=140,
            colors=colors,
            pctdistance=0.75,
            labeldistance=1.12,
            textprops={"color": "#e2e8f0", "fontsize": 10},
            wedgeprops={"linewidth": 1.5, "edgecolor": "#1e293b"},
        )
        for t in autotexts:
            t.set_color("#0f172a")
            t.set_fontweight("bold")
        ax.axis("equal")
        ax.set_title(title, color="#f1f5f9")
        if len(data) > 6:
            ax.legend(wedges, [f"{c}: {v:,.2f}" for c, v in data.items()],
                      loc="center left", bbox_to_anchor=(1.05, 0.5),
                      fontsize=9, facecolor="#1e293b", edgecolor="#334155",
                      labelcolor="#e2e8f0")
        fig.subplots_adjust(left=0.1, right=0.72 if len(data) > 6 else 0.9)
        buf = io.BytesIO()
        fig.savefig(buf, format="png", bbox_inches="tight",
                    facecolor=fig.get_facecolor())
        plt.close(fig)
        return base64.b64encode(buf.getvalue()).decode("ascii")

    colors = plt.get_cmap(cmap)(range(len(data)))

    if kind == "bar":
        labels = [s[:20] for s in data.index]
        ax.bar(labels, data.values, color=colors)
        ax.set_ylabel("Amount")
        for i, v in enumerate(data.values):
            ax.text(i, v, f"{v:,.2f}", ha="center", va="bottom", fontsize=9)

    ax.set_title(title)
    fig.tight_layout()

    buf = io.BytesIO()
    fig.savefig(buf, format="png")
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode("ascii")


def parse_csv(content):
    df = pd.read_csv(io.StringIO(content.decode("utf-8")))
    return df


def extract_category(narration):
    """Extract a merchant/category name from a bank statement narration."""
    n = str(narration).strip().strip('"').upper()
    tokens = [t.strip() for t in n.split("-")]
    tokens = [t for t in tokens if t]

    while tokens and tokens[0] in CHANNEL_PREFIXES:
        tokens = tokens[1:]

    parts = []
    for t in tokens:
        if "@" in t:
            break
        if re.search(r"\d{4,}", t):
            if re.fullmatch(r"\d{8,}", t):
                continue
            if re.fullmatch(r"[A-Z]{4,8}\d{4,}", t) and not parts:
                continue
            break
        if re.fullmatch(r"[A-Z]{4,6}\d{4,}", t):
            continue
        if re.fullmatch(r"X{4,}\d{3,}", t):
            break
        if t in STOP_TOKENS:
            break
        parts.append(t)

    merchant = " ".join(parts).strip()
    for junk in (" PAYMENT FOR", " SALARY FOR", " YOU ARE PAYING FOR", " NO REMARK"):
        merchant = merchant.replace(junk, "")
    merchant = merchant.strip(" -")
    if not merchant and tokens:
        merchant = tokens[0].split("@")[0].strip()
    return merchant or "OTHERS"


def parse_bank_statement(content, filename):
    """Parse an HDFC bank account statement (.xls/.xlsx)."""
    engine = "xlrd" if filename.lower().endswith(".xls") else "openpyxl"
    raw = pd.read_excel(io.BytesIO(content), header=None, engine=engine)

    header_idx = None
    for idx, row in raw.iterrows():
        if str(row.iloc[0]).strip() == "Date" and "Narration" in str(row.iloc[1]):
            header_idx = idx
            break
    if header_idx is None:
        raise ValueError("Statement header (Date, Narration) not found")

    records = []
    for idx in range(header_idx + 2, len(raw)):
        row = raw.iloc[idx]
        date_cell = str(row.iloc[0]).strip() if pd.notna(row.iloc[0]) else ""
        if not DATE_RE.match(date_cell):
            continue
        narration = str(row.iloc[1]) if pd.notna(row.iloc[1]) else ""
        withdrawal = pd.to_numeric(row.iloc[4], errors="coerce")
        deposit = pd.to_numeric(row.iloc[5], errors="coerce")

        if pd.notna(withdrawal):
            txn_type, amount = "Debit", withdrawal
        elif pd.notna(deposit):
            txn_type, amount = "Credit", deposit
        else:
            continue

        records.append({
            "Date": pd.to_datetime(date_cell, format="%d/%m/%y"),
            "Type": txn_type,
            "Category": extract_category(narration),
            "Amount": amount,
        })

    if not records:
        raise ValueError("No transactions found in the statement")

    return pd.DataFrame(records)


def parse_uploaded_file(filename, content):
    lower = filename.lower()
    if lower.endswith(".csv"):
        return parse_csv(content)
    if lower.endswith((".xls", ".xlsx")):
        return parse_bank_statement(content, filename)
    raise ValueError("Unsupported file type. Upload a .csv, .xls or .xlsx file.")


def validate_columns(df):
    return all(col in df.columns for col in REQUIRED_COLUMNS)


@app.route("/", methods=["GET"])
def index():
    return render_template("index.html", result=None)


@app.route("/upload", methods=["POST"])
def upload():
    file = request.files.get("csv_file")
    if not file or file.filename == "":
        return render_template("index.html", error="Please select a file to upload.")

    allowed = (".csv", ".xls", ".xlsx")
    if not file.filename.lower().endswith(allowed):
        return render_template(
            "index.html", error="Unsupported file type. Upload a .csv, .xls or .xlsx file."
        )

    try:
        df = parse_uploaded_file(file.filename, file.read())
    except ValueError as e:
        return render_template("index.html", error=str(e))
    except Exception:
        return render_template(
            "index.html",
            error="Could not read the file. Check that it is a valid CSV, XLS or XLSX.",
        )

    if not validate_columns(df):
        return render_template(
            "index.html",
            error=f"CSV must contain columns: {', '.join(REQUIRED_COLUMNS)}",
        )

    df, summary, top5_table, spending, income, monthly = analyze_transactions(df)

    top5_chart = make_chart(spending.head(5), "Top 5 Spending Categories", "bar")
    spend_pie = make_chart(spending, "Spending Breakdown by Category", "pie")

    monthly_chart = None
    if not monthly.empty:
        monthly_chart = make_chart(
            monthly.sum(axis=1).sort_index(), "Monthly Total Flow", "bar"
        )

    result = {
        "summary": summary,
        "top5": top5_table,
        "top5_chart": top5_chart,
        "spend_pie": spend_pie,
        "monthly_chart": monthly_chart,
        "total_transactions": len(df),
        "date_min": df["Date"].min().date(),
        "date_max": df["Date"].max().date(),
        "income_categories": income.reset_index().values.tolist(),
    }

    return render_template("index.html", result=result)


if __name__ == "__main__":
    app.run(debug=True)