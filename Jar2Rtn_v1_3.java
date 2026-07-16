/*
java Jar2Rtn_v1_3 <decompileDir> <jarFile> <outputDir> <cfrJar> [--decompile]
java Jar2Rtn_v1_3 JAVA_CODE C:\1.gmurugan-luxoft\1.DXC-products\reconstruct-src-infobasic\POC\jar2rtn-ui\ROUTINE.RECONSTRUCT.POC.jar JBC_CODE C:\1.gmurugan-luxoft\1.DXC-products\reconstruct-src-infobasic\POC\jar2rtn-ui\code\cfr-0.152.jar --decompile
*/
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Jar2Rtn_v1_3 {
    private static final Set<String> JBC_KEYWORDS = new LinkedHashSet<>(Arrays.asList(
            "@AM @FM @VM @SM @TM @CALLSTACK @CODEPAGE @DATA @DATE @DAY @EOF @FILENAME @FOOTER.BREAK @HEADER.BREAK @ID @LEVEL @LOCALE @LPTRHIGH @MONTH @PARASENTENCE @PATH @PID @RECORD @SELECTED @TERMTYPE @TIME @TIMEZONE @TTY @UID @USER.ROOT @USER.THREAD @USERSTATS ABORT ABS ABSS ADDS ALPHA AND ANDS ASCII ASSIGNED BITAND BITCHANGE BITCHECK BITLOAD BITNOT BITOR BITRESET BITSET BITTEST BITXOR BREAK ON OFF BYTELEN CALL CALLC CALLdotNET CALLJ CALLJEE CALLONEXIT CASE BEGIN END CATALOG CATS CHAIN CHANGE TO IN CHAR CHARS CHDIR CHECKSUM CLEAR CLEARCOMMON CLEARDATA CLEARFILE SETTING ERROR CLEARINPUT CLEARSELECT CLOSE CLOSESEQ COL1 COL2 COLLECTDATA COMMON COMPARE CONTINUE CONVERT COS COUNT COUNTS CREATE THEN ELSE CRT DATA DATE DCOUNT DEBUG DECATALOG DELETE-CATALOG DECRYPT DEFC DEFCE INT FLOAT VAR DEFFUN MAT DEL DELETE DELETELIST DELETESEQ LOCKED DELETEU DIMENSION DIM DIR DIV DIVS DOWNCASE LOWCASE UPCASE DROUND DTX DYNTOXML ECHO ENCRYPT ENTER EQS EQUATE EQU EREPLACE EXECUTE PERFORM CAPTURING RETURNING PASSLIST RTNLIST PASSDATA RTNDATA EXIT EXP EXTRACT FADD FDIV FMUL FIELD FIELDS FILEINFO FILELOCK FILEUNLOCK FIND FINDSTR FORMLIST FLUSH FMT FMTS FOLD FOOTING FOR STEP WHILE UNTIL NEXT FSUB FUNCTION GES GET FROM WAITING GETCWD GETENV GETLIST GETUSERGROUP GETX GOSUB GOTO GO GROUP GROUPSTORE USING HEADING HEADINGE HEADINGN HUSH ICONV ICONVS IF IFS INDEX INMAT INPUT WITH INPUTCLEAR INPUTNULL INS BEFORE INSERT IOCTL ISALPHA ISALNUM ISCNTRL ISDIGIT ISLOWER ISPRINT ISSPACE ISUPPER ITYPE KEYIN LATIN1 LEFT LEN LENDP LENS LES LN LOCALDATE LOCALTIME LOCATE BY LOCK LOOP DO REPEAT LOWER MATBUILD MATCHES MATCHFIELD MATPARSE MATREAD MATREADU MATWRITE MATWRITEU MAXIMUM MINIMUM MOD MODS MSLEEP MULS NEGS NES NOBUF NOT NOTS NULL NUM NUMS OCONV OCONVS OPEN OPENDEV OPENINDEX OPENPATH OPENSEQ OPENSER OR ORS OUT PAGE PAUSE PRECISION PRINT PRINTER CLOSE PRINTERR PROCREAD PROCWRITE PROGRAM PROMPT PUTENV PWR QUOTE DQUOTE SQUOTE RAISE READ READBLK READL READLIST READNEXT READPREV READSELECT READSEQ READT READU READV READVL READVU READXML RECORDLOCKED REGEXP RELEASE REMOVE REPLACE RETURN REWIND RIGHT RND RQM SADD SDIV SEEK SELECT SEND SENDX SENTENCE SEQ SEQS SIN SLEEP SMUL SORT SOUNDEX SPACE SPACES SPLICE SPOOLER SQRT SSELECT SSELECTN SSELECTV SSUB STATUS STOP STR STRS SUBROUTINE SUBS SUBSTRINGS SUM SWAP SYSTEM TAN TIMEDATE TIMEDIFF TIMEOUT TIMESTAMP TRANS TRANSABORT TRANSEND TRANSQUERY TRANSTART SYNC TRIM TRIMB TRIMBS TRIMF TRIMFS UNASSIGNED UNIQUEKEY UNLOCK UDTEXECUTE UTF8 WAKE WEOF WEOFSEQ WRITE WRITEBLK WRITELIST WRITESEQ WRITESEQF WRITET WRITEU WRITEV WRITEVU WRITEXML XLATE XMLTODYN XMLTOXML XTD"
                    .split("\\s+")));

    private static final class Encoded {
        final String text;
        final LinkedHashMap<String, String> map;
        Encoded(String text, LinkedHashMap<String, String> map) {
            this.text = text;
            this.map = map;
        }
    }

    private static Encoded encodeString(String line) {
        return encodeString(line, "##STRINGS{}##");
    }

    private static Encoded encodeString(String line, String key) {
        String outputLine = line.replace("\\\\", "##DOUBLEBACKSLASH##").replace("\\\"", "\" : '\"' : \"");
        int count = -1;
        LinkedHashMap<String, String> map = new LinkedHashMap<>();
        while (outputLine.contains("\"") || outputLine.contains("'")) {
            count++;
            String currentKey = key.replace("{}", Integer.toString(count));
            int dq = outputLine.indexOf('"') < 0 ? outputLine.length() : outputLine.indexOf('"');
            int sq = outputLine.indexOf('\'') < 0 ? outputLine.length() : outputLine.indexOf('\'');
            char delim = dq < sq ? '"' : '\'';
            int start = outputLine.indexOf(delim);
            int end = outputLine.indexOf(delim, start + 1);
            if (start < 0 || end < 0) {
                break;
            }
            map.put(currentKey, delim + outputLine.substring(start + 1, end) + delim);
            outputLine = outputLine.substring(0, start) + currentKey + outputLine.substring(end + 1);
        }
        return new Encoded(outputLine, map);
    }

    private static String decodeString(String line, Map<String, String> map) {
        String out = line;
        for (Map.Entry<String, String> e : map.entrySet()) {
            out = out.replace(e.getKey(), e.getValue());
        }
        return out.replace("##DOUBLEBACKSLASH##", "\\\\");
    }

    private static List<String> split(String s, String literal) {
        return new ArrayList<>(Arrays.asList(s.split(Pattern.quote(literal), -1)));
    }

    private static String join(String sep, List<String> values) {
        return String.join(sep, values);
    }

    private static int count(String s, String needle) {
        int c = 0;
        for (int i = s.indexOf(needle); i >= 0; i = s.indexOf(needle, i + needle.length())) c++;
        return c;
    }

    private static List<String> findAll(String regex, String text) {
        Matcher m = Pattern.compile(regex).matcher(text);
        List<String> out = new ArrayList<>();
        while (m.find()) out.add(m.group());
        return out;
    }

    private static List<String> uniqueSortedFindAll(String regex, String text) {
        List<String> out = new ArrayList<>(new LinkedHashSet<>(findAll(regex, text)));
        Collections.sort(out);
        return out;
    }

    private static List<String> reversed(List<String> in) {
        List<String> out = new ArrayList<>(in);
        Collections.reverse(out);
        return out;
    }

    private static String repeat(String s, int n) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < n; i++) b.append(s);
        return b.toString();
    }

    private static String sliceJoin(String sep, List<String> values, int fromInclusive, int toExclusive) {
        int from = Math.max(0, fromInclusive);
        int to = Math.min(values.size(), toExclusive);
        if (from >= to) return "";
        return String.join(sep, values.subList(from, to));
    }

    public static List<String> methodExtractor(String javaCode, String methodName) {
        int openCount = 0;
        int closeCount = 0;
        if (!javaCode.contains(methodName)) {
            System.out.println("\nMETHOD NAME NOT FOUND IN JAVA CODE\n***************************\n" + methodName + "\n***************************\n");
            if (javaCode.contains(methodName.trim())) {
                System.out.println("\nFOUND METHOD NAME IN JAVA CODE\n===========================\n" + methodName.trim() + "\n===========================\n");
            }
            return new ArrayList<>();
        }
        int leadingNewlines = 0;
        while (methodName.startsWith("\n")) {
            leadingNewlines++;
            methodName = methodName.substring(1);
        }
        int pos = javaCode.indexOf(methodName);
        String before = javaCode.substring(0, pos);
        String prefix = before.contains("\n") ? before.substring(before.lastIndexOf('\n') + 1) : before;
        String codeSuffix = prefix + methodName + javaCode.substring(pos + methodName.length());
        Encoded enc = encodeString(codeSuffix);
        List<String> lines = split(enc.text, "\n");
        List<String> out = new ArrayList<>();
        for (String line : lines) {
            openCount += count(line, "{");
            closeCount += count(line, "}");
            out.add(line);
            if (openCount == closeCount && openCount > 0) break;
        }
        String decoded = decodeString(join("\n", out), enc.map);
        List<String> decodedLines = split(decoded, "\n");
        for (int i = 0; i < leadingNewlines; i++) decodedLines.add(0, "");
        return decodedLines;
    }

    public static Map<String, String> gosubLabelExtractor(String javaCode) {
        Map<String, String> map = new LinkedHashMap<>();
        for (String codeLine : split(javaCode, " final int lbl_").subList(1, split(javaCode, " final int lbl_").size())) {
            String raw = split(codeLine, "=").get(0).trim();
            map.put("lbl_" + raw, raw.replace("_", "."));
        }
        return map;
    }

    public static String getJbcCode(String javaCode) {
        List<String> names = new ArrayList<>();
        names.add("main");
        names.addAll(gosubLabelExtractor(javaCode).keySet());
        List<String> blocks = new ArrayList<>();
        for (String name : names) {
            blocks.add(join("\n", methodExtractor(javaCode, " int " + name + "() {")));
        }
        return join("\n", blocks);
    }

    public static String convertJavaToJbcStandards(String originalCode) {
        Encoded enc = encodeString(originalCode);
        String code = enc.text.replace("(Object)", "");
        String[] componentCommonVariables = {
                "\\bcomponent\\_[A-Z]+_\\w+_[0-9]+_cl[0-9]*\\.get\\w+\\b",
                "\\bcomponent\\_[A-Z]+_\\w+_[0-9]+_cl[0-9]*\\.set\\w+\\b"
        };
        for (String regex : componentCommonVariables) {
            for (String v : uniqueSortedFindAll(regex, code)) {
                List<String> pack = split(split(v, ".").get(0), "_");
                String to = sliceJoin(".", pack, 1, pack.size() - 2) + "." + split(v, ".").get(1);
                code = code.replace(v, to);
            }
        }
        for (String v : reversed(uniqueSortedFindAll("\\n\\s+this\\.get[A-Z]+_\\w+\\(\\)\\s*;", code))) code = code.replace(v, "\n");
        for (String v : reversed(uniqueSortedFindAll("\\bthis\\.get[A-Z]+_\\w+\\(\\)\\.\\w+_*\\w+", code))) {
            String pack = split(split(v, "this.get").get(1), "(").get(0).replace("_", ".");
            String tableFunc = split(v, ".").get(2).replace("_", ".");
            code = code.replace(v, pack + "." + tableFunc);
        }
        for (String v : reversed(findAll("\\bcomponent_[A-Z]+_\\w+_[0-9]+_cl\\._\\w+_\\w+\\b", code))) {
            List<String> p = split(split(v, "._").get(0), "_");
            String component = sliceJoin("_", p, 1, p.size() - 2).replace("_", ".");
            String field = split(v, "._").get(split(v, "._").size() - 1).replace("_", ".");
            code = code.replace(v, component + "." + field);
        }
        for (String v : reversed(findAll("\\bthis\\.[A-Z]+_\\w+\\.\\w+\\b", code))) code = code.replace(v, v.substring(5).replace("_", "."));
        for (String v : reversed(findAll("\\bthis\\._\\w*\\b", code))) {
            if (!v.trim().endsWith("_") && !v.equals("this._l")) {
                code = code.replace(v, v.replace("this._", "").replace("_d_", "$").replace("_", ".").replace("..", "_").trim());
            }
        }
        for (String n : reversed(findAll("[,()\\s:+\\-*/%<][0-9]+L", code))) code = code.replace(n, n.substring(0, n.length() - 1));
        return decodeString(code, enc.map);
    }

    public static String handleGosubs(String javaCode) {
        String out = javaCode;
        String[] patterns = {
                "this\\._Sys_PostGlobus\\s*=\\s*this\\.lbl_\\w+\\(\\);\\s*if\\s*\\(this\\._Sys_PostGlobus\\s*!=\\s*-1\\)\\s*\\{\\s*return\\s*this\\._Sys_PostGlobus;\\s*}",
                "this\\._Sys_PostGlobus\\s*=\\s*this\\.lbl_\\w+\\(\\);\\s*if\\s*\\(this\\._Sys_PostGlobus\\s*==\\s*-1\\)\\s*break;\\s*return\\s*this\\._Sys_PostGlobus;"
        };
        for (String p : patterns) {
            for (String found : findAll(p, out)) {
                String label = split(split(found, "this._Sys_PostGlobus = this.lbl_").get(1), "(").get(0);
                String jbc = convertJavaToJbcStandards(label).replace("_d_", "$").replace("_", ".").replace("..", "_");
                out = out.replace(found, "GOSUB " + jbc);
            }
        }
        return out;
    }

    public static String methodNamesToGosubLabels(String javaCode) {
        String out = javaCode;
        Matcher m = Pattern.compile("}\\s*(public|private|protected)\\s+int\\s+lbl_\\w+\\s*\\(\\)\\s*\\{").matcher(javaCode);
        while (m.find()) {
            String found = m.group();
            String label = split(split(split(found.trim(), " int ").get(1), "(").get(0), "lbl_").get(1);
            String jbc = convertJavaToJbcStandards(label).replace("_d_", "$").replace("_", ".").replace("..", "_");
            out = out.replace(found, "RETURN\n    " + jbc + ":");
        }
        return out;
    }

    public static String methodCallsToCallStmts(String javaCode) {
        String out = javaCode;
        String[] callAtPatterns = {
                "\\s*this\\.CALL_AT\\(.*,\\s*new\\s*Object\\[[0]*\\].*\\);\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\) == \\-3\\)\\s*\\{\\s*return\\s*\\-3;\\s*\\}"
        };
        for (String p : callAtPatterns) {
            for (String found : findAll(p, out)) {
                String prefix = found.substring(0, found.indexOf(found.trim()));
                String codeLine = split(found, ";").get(0).replace(".toString()", "");
                String rtnVariable = split(split(codeLine, ",").get(0), "(").get(split(split(codeLine, ",").get(0), "(").size() - 1);
                String args = codeLine.contains("Object[0]") ? "" : "(" + split(split(codeLine, "{").get(1), "}").get(0) + ")";
                out = out.replace(found, prefix + "CALL @" + rtnVariable + args);
            }
        }
        String[] patterns = {
                "if \\(this\\.session\\.isUnitTest\\(\\)\\) \\{\\s*this\\.session\\.findStub\\(new String\\[\\]\\{.*\\}\\)\\.invoke\\(new Object\\[[0]*\\].*\\);\\s*}\\s*else\\s*\\{\\s*[\\w]+\\.INSTANCE\\(\\(jSession\\)this\\.session\\)\\.invoke\\(new\\sObject\\[[0]*\\]\\{*.*\\}*\\);\\s*\\}\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\)\\s*\\=\\=\\s*\\-3\\)\\s*\\w*;*\\{\\s*return -3;\\s*\\}",
                "if \\(this\\.session\\.isUnitTest\\(\\)\\) \\{\\s*this\\.session\\.findStub\\(new String\\[\\]\\{.*\\}\\)\\.invoke\\(new Object\\[[0]*\\].*\\);\\s*}\\s*else\\s*\\{\\s*[\\w]+\\.INSTANCE\\(this\\.session\\)\\.invoke\\(new\\sObject\\[[0]*\\]\\{*.*\\}*\\);\\s*\\}\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\)\\s*\\=\\=\\s*\\-3\\)\\s*\\w*;*\\{\\s*return -3;\\s*\\}"
        };
        for (String p : patterns) {
            for (String found : findAll(p, out)) {
                String rtn = split(found.trim(), "\"").size() > 1 ? split(found.trim(), "\"").get(1) : "";
                List<String> parts = split(found, "new Object[]");
                String args = "";
                if (parts.size() > 4) args = "(" + split(join("new Object[]", parts.subList(1, parts.size())), "});").get(0).substring(join("new Object[]", parts.subList(1, parts.size())).indexOf('{') + 1) + ")";
                else if (parts.size() > 2) args = "(" + split(split(parts.get(2), "{").get(1), "}").get(0) + ")";
                out = out.replace(found, "CALL " + convertJavaToJbcStandards(rtn) + convertJavaToJbcStandards(args));
            }
        }
        String[] directPatterns = {
                "\\s*\\w+_cl\\.INSTANCE\\(\\(jSession\\)this\\.session\\).invoke\\(new Object\\[[0]*\\].*\\);\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\)\\s*\\=\\=\\s*-3\\)\\s*\\{\\s*return\\s*\\-3;\\s*\\}",
                "\\s*\\w+_cl\\.INSTANCE\\(this\\.session\\).invoke\\(new Object\\[[0]*\\].*\\);\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\)\\s*\\=\\=\\s*-3\\)\\s*\\{\\s*return\\s*\\-3;\\s*\\}",
                "\\s*\\w+_cl\\.INSTANCE\\(\\(jSession\\)this\\.session\\).invoke\\(new Object\\[[0]*\\].*\\);\\s*if\\s*\\(this\\.session\\.getStateSubroutineAfterCall\\(\\)\\s*\\!\\=\\s*-3\\)\\s*continue;"
        };
        for (String p : directPatterns) {
            for (String found : findAll(p, out)) {
                String prefix = found.substring(0, found.indexOf(found.trim()));
                String rtn = split(found.trim(), "_cl.INSTANCE").get(0).replace("_", ".");
                List<String> parts = split(found, "new Object[]");
                String args = "";
                if (parts.size() > 2) {
                    String rest = join("new Object[]", parts.subList(1, parts.size()));
                    args = "(" + split(rest.substring(rest.indexOf('{') + 1), "});").get(0) + ")";
                } else if (parts.size() > 1 && parts.get(1).contains("{")) {
                    args = "(" + split(split(parts.get(1), "{").get(1), "}").get(0) + ")";
                }
                out = out.replace(found, prefix + "CALL " + convertJavaToJbcStandards(rtn) + convertJavaToJbcStandards(args));
            }
        }
        return out;
    }

    public static String handleInserts(String javaCode) {
        String out = javaCode;
        for (String found : findAll("this.INSERT__I__.*\\(\\);", out)) {
            String insert = split(split(found.trim(), "this.INSERT__").get(1), "(").get(0);
            out = out.replace(found, "$INSERT " + insert.replace("_", ".").replace("..", "_"));
        }
        return out;
    }

    public static List<String> extractMethodArguments(String javaCode, String functionName) {
        Encoded enc = encodeString(javaCode, "##STRINGENCODEKEY{}##");
        String code = enc.text;
        String key = functionName + "(";
        if (!code.contains(key)) return new ArrayList<>();
        String used = split(split(split(code, key).get(split(code, key).size() - 1), ";").get(0), "\n").get(0);
        List<String> raw = split(used, ",");
        int open = 0, close = 0;
        String cur = "";
        List<String> args = new ArrayList<>();
        for (String arg : raw) {
            open += count(arg, "(");
            close += count(arg, ")");
            cur += arg + ",";
            if (open == close) {
                args.add(cur.substring(0, cur.length() - 1));
                cur = "";
            }
            if (open < close) {
                int diff = open - close;
                List<String> pieces = split(cur, ")");
                cur = join(")", pieces.subList(0, Math.max(0, pieces.size() + diff)));
                args.add(cur);
                break;
            }
        }
        List<String> decoded = new ArrayList<>();
        for (String a : args) decoded.add(decodeString(a, enc.map));
        return decoded;
    }

    public static String extractMethodArgument(String javaCode, String functionName, int position) {
        List<String> args = extractMethodArguments(javaCode, functionName);
        if (position > args.size() - 1) {
            System.out.println("** ERROR ** [Trying To Access " + position + " In argumentsArray " + args + "]");
            return "";
        }
        return args.get(position);
    }

    public static String handleForLoops(String javaCode) {
        String out = javaCode;
        for (String found : uniqueSortedFindAll("\\sblock[0-9]*\\:\\s\\{", out)) {
            String block = split(found, ":").get(0).trim();
            String fromBlock = join("\n", methodExtractor(out, found));
            List<String> strippedLines = split(fromBlock.trim(), "\n");
            String withoutFirstLine = strippedLines.size() > 1 ? join("\n", strippedLines.subList(1, strippedLines.size())) : "";
            List<String> blockParts = split(withoutFirstLine, "}");
            String toBlock = sliceJoin("}", blockParts, 0, blockParts.size() - 1) + block.toUpperCase() + ":";
            out = out.replace(fromBlock, toBlock).replace(" break " + block + ";", " GOTO " + block.toUpperCase() + ";");
        }
        String[] patterns = {
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*this\\._l\\(.*\\);\\s*this\\._\\w+\\s*=\\s*.*;",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*this\\._\\w+\\s*=\\s*.*;",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*this\\._l\\(.*\\);\\s*this\\.set\\(.*\\);",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*this\\.set\\(.*\\);",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*.*\\s*this\\._\\w+\\s*=\\s*.*;",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*.*\\s*this\\.set\\(.*\\);",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(true\\)\\s*\\{\\s*if\\s*\\(\\!this\\._TestFor_\\(.*\\)\\)\\s*GOTO\\s*BLOCK[0-9]*;\\s*this\\.set\\(.*\\);",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(true\\)\\s*\\{[\\s\\S]*?if\\s*\\(\\!this\\._TestFor_\\(.*\\)\\)\\s*GOTO\\s*BLOCK[0-9]*;\\s*this\\.set\\(.*\\);",
                "\\s*while\\s*\\(this\\._TestFor_\\(.*\\)\\)\\s*\\{\\s*this\\.set\\(.*\\);"
                ,
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(true\\)\\s*\\{[\\s\\S]*?if\\s*\\(\\!this\\._TestFor_\\(.*\\)\\)\\s*break;\\s*this\\.set\\(.*\\);",
                ".*\\s\\w+\\s*=\\s*.*;\\s*while\\s*\\(true\\)\\s*\\{[\\s\\S]*?if\\s*\\(\\!this\\._TestFor_\\(.*\\)\\)\\s*\\{[\\s\\S]*?\\}\\s*this\\.set\\(.*\\);"
        };
        for (String p : patterns) {
            for (String found : findAll(p, out)) {
                List<String> blockIfLines = new ArrayList<>();
                for (String line : split(found, "\n")) {
                    if (line.trim().contains("_TestFor_")) break;
                    String trimmed = line.trim();
                    if (trimmed.length() < 5 || !trimmed.substring(0, 5).equalsIgnoreCase("while")) {
                        blockIfLines.add(line);
                    }
                }
                String blockIfStmts = join("\n", blockIfLines);
                String methodCode = join("\n", methodExtractor(out, found));
                if (methodCode.isEmpty()) continue;
                String indent = methodCode.substring(0, methodCode.indexOf(found.trim()));
                List<String> methodSplit = split(methodCode, found);
                String joinedAfterPattern = methodSplit.size() > 1 ? join(found, methodSplit.subList(1, methodSplit.size())) : "";
                List<String> subParts = split(joinedAfterPattern, "}");
                String sub = sliceJoin("}", subParts, 0, subParts.size() - 1);
                String loopVar;
                String loopVar2;
                if (found.contains("this.set")) {
                    loopVar = convertJavaToJbcStandards(extractMethodArgument(found, "this.set", 0)).trim();
                    loopVar2 = convertJavaToJbcStandards(extractMethodArgument(found, "this.set", 1)).trim();
                } else {
                    String last = split(found.trim(), "\n").get(split(found.trim(), "\n").size() - 1);
                    loopVar = split(last, "=").get(0).trim();
                    loopVar2 = split(split(last, "=").get(1), ";").get(0).trim();
                }
                String init = "1";
                if (found.contains(loopVar2 + " =")) {
                    String tmp = split(found, loopVar2 + " =").get(1);
                    tmp = split(tmp, ";").get(0).replace(")", " ").trim();
                    List<String> words = split(tmp, " ");
                    init = convertJavaToJbcStandards(words.get(words.size() - 1)).trim();
                }
                String last = convertJavaToJbcStandards(extractMethodArgument(found, "_TestFor_", 1)).trim();
                String step = convertJavaToJbcStandards(extractMethodArgument(found, "_TestFor_", 2)).trim();
                out = out.replace(methodCode, indent + "FOR " + loopVar + " = " + init + " TO " + last + " STEP " + step + " \n" + blockIfStmts + "\n" + sub + "\n" + indent + "NEXT " + loopVar + "\n");
            }
        }
        return out;
    }

    public static String findAndReplaceRegex(String code, String regex, String replacement) {
        for (String found : findAll(regex, code)) code = code.replace(found, replacement);
        return code;
    }

    public static String handleSwitchFunction(String javaCode) {
        String out = javaCode;
        for (String found : findAll("\\s*switch\\s*\\(this\\..*\\(.*\\)\\)\\s*\\{", javaCode)) {
            String foundTo = split(found, " {").get(0);
            String current = join("\n", methodExtractor(out, found));
            if (current.isEmpty()) continue;
            String args = extractMethodArgument(found, "switch ", 0);
            for (String br : uniqueSortedFindAll("\\n\\s+break\\s*;\\s+\\}\\s+\\w+[0-9]*\\:\\s+\\{", current)) {
                current = current.replace(br, "\n" + split(br, ";").get(split(br, ";").size() - 1));
            }
            String c0 = current.contains("case 0: {") ? join("\n", methodExtractor(current, "case 0: {")) : "";
            String c1 = current.contains("case 1: {") ? join("\n", methodExtractor(current, "case 1: {")) : "";
            String c3 = current.contains("case 3: {") ? join("\n", methodExtractor(current, "case 3: {")) : "";
            String cd = current.contains("default: {") ? join("\n", methodExtractor(current, "default: {")) : "";
            String then = c0.isEmpty() ? "" : split(c0, "case 0: {").get(0) + " THEN" + sliceJoin("}", split(split(c0, "case 0: {").get(1), "}"), 0, split(split(c0, "case 0: {").get(1), "}").size() - 1) + "END\n";
            String els = "";
            if (!c1.isEmpty()) els = split(c1, "case 1: {").get(0) + " ELSE" + sliceJoin("}", split(split(c1, "case 1: {").get(1), "}"), 0, split(split(c1, "case 1: {").get(1), "}").size() - 1) + "END\n";
            else if (!cd.isEmpty()) els = split(cd, "default: {").get(0) + " ELSE" + sliceJoin("}", split(split(cd, "default: {").get(1), "}"), 0, split(split(cd, "default: {").get(1), "}").size() - 1) + "END\n";
            String onErr = c3.isEmpty() ? "" : split(c3, "case 3: {").get(0) + " ON ERROR" + sliceJoin("}", split(split(c3, "case 3: {").get(1), "}"), 0, split(split(c3, "case 3: {").get(1), "}").size() - 1) + "END\n";
            String thenElse = findAndReplaceRegex(findAndReplaceRegex(then + "\n" + els, "\\s*THEN", " THEN"), "\\s*ELSE", " ELSE");
            String onError = findAndReplaceRegex(onErr, "\\s*ON ERROR", " ON ERROR");
            if (thenElse.trim().isEmpty()) thenElse = onError;
            if (thenElse.trim().isEmpty()) thenElse = " ELSE NULL";
            out = out.replace(current, (foundTo + thenElse).replace(foundTo.trim(), args));
        }
        return out;
    }

    public static String convertJavaFunctionsToJbc(String originalLine) {
        return convertJavaFunctionsToJbc(originalLine, false);
    }

    public static String convertJavaFunctionsToJbc(String originalLine, boolean concatAdjFlag) {
        Encoded enc = encodeString(originalLine);
        String line = enc.text;
        Map<String, String> history = new LinkedHashMap<>();
        int cnt = 0, max = -1;
        while (line.contains("(") && line.contains(")")) {
            String key = "#VAR" + cnt + "#";
            String beforeParen = line.substring(0, line.lastIndexOf('('));
            String name = beforeParen;
            for (String sep : new String[]{")", ",", ":", "{", "}", ";", " ", "#", "("}) {
                List<String> parts = split(name, sep);
                name = parts.get(parts.size() - 1);
            }
            name = name.trim();
            String args = split(line.substring(line.lastIndexOf('(') + 1), ")").get(0);
            String deepest = name + "(" + args + ")";
            String out = convertFunction(name, args, deepest);
            out = convertJavaToJbcStandards(out);
            history.put(key, out.trim());
            line = line.replace(deepest, key);
            max = cnt++;
            if (cnt > 2000) break;
        }
        for (int i = max; i >= 0; i--) {
            String key = "#VAR" + i + "#";
            line = line.replace(key, history.getOrDefault(key, key));
        }
        String trimmed = line.trim();
        String first = trimmed.isEmpty() ? "" : split(trimmed, " ").get(0);
        if (concatAdjFlag && !JBC_KEYWORDS.contains(first) && !line.contains("=") && line.contains(":") && !trimmed.endsWith(":")) {
            List<String> p = split(line, ":");
            line = p.get(0) + ":=" + sliceJoin(":", p, 1, p.size());
        }
        return decodeString(line, enc.map);
    }

    private static List<String> csvArgs(String args) {
        List<String> out = new ArrayList<>();
        for (String a : split(args, ",")) out.add(a.trim());
        return out;
    }

    private static List<String> nonNullArgs(List<String> args) {
        List<String> out = new ArrayList<>();
        for (String a : args) if (!a.equals("Objectnull") && !a.equals("null")) out.add(a.trim());
        return out;
    }

    private static String convertFunction(String name, String argsText, String deepest) {
        List<String> args = csvArgs(argsText);
        if ("this.get".equals(name)) {
            List<String> nz = new ArrayList<>();
            for (String a : args) if (!a.equals("0")) nz.add(a);
            return nz.get(0) + "<" + sliceJoin(", ", nz, 1, nz.size()) + ">";
        } else if (name.contains("newjPosition")) {
            return "[" + String.join(", ", args) + "]";
        } else if ("this.set".equals(name)) {
            List<String> nz = new ArrayList<>();
            nz.add(args.get(0));
            for (int i = 1; i < args.size() - 1; i++) if (!args.get(i).equals("0")) nz.add(args.get(i));
            nz.add(args.get(args.size() - 1));
            if (args.size() == 2) return nz.get(0) + " = " + nz.get(1) + ";";
            if (args.size() == 3) return args.get(0) + args.get(2) + " = " + args.get(1) + ";";
            if (args.size() == 5) return nz.get(0) + "<" + sliceJoin(",", nz, 1, nz.size() - 1) + "> = " + nz.get(nz.size() - 1) + ";";
        } else if (name.equalsIgnoreCase("IF")) {
            return "IF " + String.join(" ", args);
        } else if (name.contains("this.ABORT")) return "ABORT";
        else if (name.contains("this.boolVal")) return argsText;
        else if (name.contains("this.CALLJ")) return "CALLJ " + args.get(0) + ", " + args.get(1) + ", " + args.get(2) + " SETTING " + args.get(3);
        else if (name.contains("this.CHANGE_STMT") || name.contains("this.CONVERT")) {
            List<String> nz = new ArrayList<>();
            for (String a : nonNullArgs(args)) if (!a.equals("0")) nz.add(a);
            String verb = name.contains("CHANGE") ? "CHANGE" : "CONVERT";
            if (nz.size() == 3) return verb + " " + nz.get(0) + " TO " + nz.get(1) + " IN " + nz.get(2);
            if (nz.size() >= 4) return verb + " " + nz.get(0) + " TO " + nz.get(1) + " IN " + nz.get(2) + "<" + sliceJoin(",", nz, 3, nz.size()) + ">";
        } else if (name.contains("this.CHANGE")) return "CHANGE(" + argsText + ")";
        else if (name.contains("this.CHDIR")) return "CHDIR(" + argsText + ")";
        else if (name.contains("this.CLEARFILE")) return "CLEARFILE " + nonNullArgs(args).get(0);
        else if (name.contains("this.CLEARSELECT")) return "CLEARSELECT";
        else if (name.contains("this.CLOSESEQ")) return "CLOSESEQ " + nonNullArgs(args).get(0);
        else if (name.contains("this.CLOSE")) return "CLOSE " + nonNullArgs(args).get(0);
        else if (name.contains("this.CREATE")) return "CREATE " + nonNullArgs(args).get(0);
        else if (name.contains("this.CRT")) return "CRT " + argsText.trim();
        else if (name.contains("this.DEBUG")) return "DEBUG";
        else if (name.contains("this.DELETE_STMT")) return "DELETE " + sliceJoin(", ", nonNullArgs(args), 0, 2);
        else if (name.contains("this.DELETESEQ")) return "DELETESEQ " + sliceJoin(", ", nonNullArgs(args), 0, 2);
        else if (name.contains("this.DEL")) {
            List<String> nn = nonNullArgs(args);
            if (nn.size() == 4) return "DEL " + nn.get(0) + "<" + nn.get(1) + ", " + nn.get(2) + ", " + nn.get(3) + ">";
            if (nn.size() == 3) return "DEL " + nn.get(0) + "<" + nn.get(1) + ", " + nn.get(2) + ">";
            if (nn.size() == 2) return "DEL " + nn.get(0) + "<" + nn.get(1) + ">";
        } else if (name.contains("this.DIM")) return "DIM " + args.get(0) + "(" + sliceJoin(",", args, 1, args.size()) + ")";
        else if (name.contains("this.EXECUTE")) {
            List<String> nn = nonNullArgs(args);
            if (nn.size() == 1) return "EXECUTE " + nn.get(0);
            if (nn.size() == 2) return "EXECUTE " + nn.get(0) + " CAPTURING " + nn.get(1);
        } else if (name.contains("this.FINDSTR")) return "FINDSTR " + nonNullArgs(args.subList(0, Math.max(0, args.size() - 1))).get(0) + " IN " + nonNullArgs(args).get(1) + " SETTING " + sliceJoin(",", nonNullArgs(args), 2, nonNullArgs(args).size()) + " ";
        else if (name.contains("this.FIND")) return "FIND " + nonNullArgs(args).get(0) + " IN " + nonNullArgs(args).get(1) + " SETTING " + sliceJoin(", ", nonNullArgs(args), 2, Math.max(2, nonNullArgs(args).size() - 1)) + " ";
        else if (name.contains("this.HEADING")) return "HEADING " + nonNullArgs(args).get(0);
        else if (name.contains("this.INPUT")) return "INPUT " + args.get(0);
        else if (name.contains("this.INS_BEFORE")) {
            List<String> nn = nonNullArgs(args);
            if (nn.size() == 5) return "INS " + nn.get(0) + " BEFORE " + nn.get(1) + "<" + nn.get(2) + ", " + nn.get(3) + ", " + nn.get(4) + ">";
            if (nn.size() == 4) return "INS " + nn.get(0) + " BEFORE " + nn.get(1) + "<" + nn.get(2) + ", " + nn.get(3) + ">";
            if (nn.size() == 3) return "INS " + nn.get(0) + " BEFORE " + nn.get(1) + "<" + nn.get(2) + ">";
        } else if (name.contains("this.LOCATE")) {
            List<String> base = args.subList(0, Math.max(0, args.size() - 1));
            List<String> nn = nonNullArgs(base);
            List<String> nz = new ArrayList<>();
            for (String a : nn) if (!a.equals("0")) nz.add(a);
            if (base.size() == 3) return "LOCATE " + base.get(0) + " IN " + base.get(1) + "<1> SETTING " + base.get(2);
            if (base.size() == 8 && nn.size() == 6) return "LOCATE " + nz.get(0) + " IN " + nz.get(1) + "<" + sliceJoin(", ", nz, 2, nz.size() - 1) + "> SETTING " + nz.get(nz.size() - 1);
            if (base.size() == 8 && nn.size() == 7) return "LOCATE " + nz.get(0) + " IN " + nz.get(1) + "<" + sliceJoin(", ", nz, 2, nz.size() - 2) + "> BY " + nz.get(nz.size() - 2) + " SETTING " + nz.get(nz.size() - 1);
            if (base.size() == 8 && nn.size() == 4) return "LOCATE " + nz.get(0) + " IN " + nz.get(1) + "<1> BY " + nz.get(2) + " SETTING " + nz.get(3);
        } else if (name.contains("this.MATCHFIELD")) return "MATCHFIELD(" + argsText + ")";
        else if (name.contains("this.MATBUILD")) return "MATBUILD " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1);
        else if (name.contains("this.MATREAD")) return "MATREAD " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1) + ", " + nonNullArgs(args).get(2);
        else if (name.contains("this.MAT")) return "MAT " + args.get(0) + " = " + args.get(1);
        else if (name.contains("this.OPENSEQ")) {
            List<String> nn = nonNullArgs(args);
            return !"false".equals(nn.get(2)) ? "OPENSEQ " + nn.get(1) + ", " + nn.get(2) + " TO " + nn.get(0) : "OPENSEQ " + nn.get(1) + " TO " + nn.get(0);
        } else if (name.contains("this.OPENPATH")) return "OPENPATH " + nonNullArgs(args).get(1) + " TO " + nonNullArgs(args).get(0);
        else if (name.contains("this.OPEN")) {
            List<String> raw = args.subList(0, Math.max(0, args.size() - 1));
            List<String> nn = nonNullArgs(raw);
            if (nn.size() == 3 && !"null".equalsIgnoreCase(args.get(0)) && !"Objectnull".equalsIgnoreCase(args.get(0))) return "OPEN " + nn.get(0) + ", " + nn.get(1) + " TO " + nn.get(2);
            if (nn.size() == 3) return "OPEN " + nn.get(0) + " TO " + nn.get(1) + " SETTING " + nn.get(2);
            if (nn.size() == 2) return "OPEN " + nn.get(0) + " TO " + nn.get(1);
            if (nn.size() == 4) return "OPEN " + nn.get(0) + ", " + nn.get(1) + " TO " + nn.get(2) + " SETTING " + nn.get(3);
        } else if (name.contains("this.PRINTER")) return args.contains("true") ? "PRINTER ON" : "PRINTER OFF";
        else if (name.contains("this.PRINT")) return "PRINT " + sliceJoin(",", args, 1, Math.max(1, args.size() - 1));
        else if (name.contains("this.READBLK")) return "READBLK " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1) + ", " + nonNullArgs(args).get(2);
        else if (name.contains("this.READNEXT")) {
            List<String> nn = new ArrayList<>();
            for (String a : args) nn.add(a.equals("Objectnull") || a.equals("null") ? "" : a);
            return ("READNEXT " + nn.get(0) + ", " + nn.get(1) + " SETTING " + nn.get(2) + " FROM " + nn.get(3) + " ").replace(",  ", " ").replace(" FROM  ", " ").replace(" SETTING  ", " ").trim();
        } else if (name.contains("this.READSEQ")) return "READSEQ " + nonNullArgs(args).get(1) + " FROM " + nonNullArgs(args).get(0);
        else if (name.contains("this.READU")) return "READU " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1) + ", " + nonNullArgs(args).get(2);
        else if (name.contains("this.READV")) return "READV " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1) + ", " + nonNullArgs(args).get(2) + ", " + nonNullArgs(args).get(3);
        else if (name.contains("this.READ")) return "READ " + nonNullArgs(args).get(0) + " FROM " + nonNullArgs(args).get(1) + ", " + nonNullArgs(args).get(2);
        else if (name.contains("this.RELEASE")) return "RELEASE " + nonNullArgs(args).get(0) + ", " + nonNullArgs(args).get(1);
        else if (name.contains("this.REMOVE")) return "REMOVE " + args.get(0) + " FROM " + args.get(1) + " SETTING " + args.get(2);
        else if (name.contains("this.SELECT")) return "SELECT " + nonNullArgs(args).get(0);
        else if (name.contains("this.STOP")) return "STOP";
        else if (name.contains("this.WEOFSEQ")) return "WEOFSEQ " + nonNullArgs(args).get(0);
        else if (name.contains("this.WRITEBLK")) return "WRITEBLK " + nonNullArgs(args).get(0) + " TO " + nonNullArgs(args).get(1);
        else if (name.contains("this.WRITESEQ")) return "WRITESEQ " + nonNullArgs(args).get(1) + " TO " + nonNullArgs(args).get(0);
        else if (name.contains("this.WRITE")) {
            List<String> nn = nonNullArgs(args);
            if (nn.size() == 4) return "WRITE " + nn.get(0) + " TO " + nn.get(1) + ", " + nn.get(2);
            if (nn.size() == 5) return "WRITE " + nn.get(0) + " TO " + nn.get(1) + ", " + nn.get(2) + " SETTING " + nn.get(3);
        } else if (name.replace("this.", "").equals(name.replace("this.", "").toUpperCase()) && !name.contains("_")) {
            return name.replace("this.", "") + "(" + argsText + ")";
        } else if (name.contains("Character.valueOf")) return argsText;
        else if (name.contains(".concat")) {
            String prefix = split(name, ".concat").get(0);
            if (prefix.startsWith("this._")) return prefix + " = " + prefix + " : " + args.get(0);
            if (prefix.startsWith("this.aGet")) return prefix + " := " + args.get(0);
            return prefix + " : " + args.get(0);
        } else if (name.contains("this.op_cat")) return args.get(0) + " : " + args.get(1);
        else if (name.contains("this.op_mult")) return "(" + String.join(" * ", args) + ")";
        else if (name.contains("this.op_neg")) return "-" + args.get(0);
        else if (name.contains("this.op_or")) return args.get(0) + " OR " + args.get(1);
        else if (name.contains("this.op_and")) return args.get(0) + " AND " + args.get(1);
        else if (name.contains("this.op_equal")) return args.get(0) + " EQ " + args.get(1);
        else if (name.contains("this.op_ne")) return args.get(0) + " NE " + args.get(1);
        else if (name.contains("this.op_ge")) return args.get(0) + " GE " + args.get(1);
        else if (name.contains("this.op_gt")) return args.get(0) + " GT " + args.get(1);
        else if (name.contains("this.op_le")) return args.get(0) + " LE " + args.get(1);
        else if (name.contains("this.op_lt")) return args.get(0) + " LT " + args.get(1);
        else if (name.contains("this.op_match")) return args.get(0) + " MATCHES " + args.get(1);
        else if (name.contains("this.op_add")) return "(" + args.get(0) + " + " + args.get(1) + ")";
        else if (name.contains("this.op_sub")) return "(" + args.get(0) + " - " + args.get(1) + ")";
        else if (name.contains("this.op_div")) return "(" + args.get(0) + " / " + args.get(1) + ")";
        else if (name.contains("this.fGet") || name.contains("this.op_fGet")) return args.get(0) + "[" + sliceJoin(", ", args, 1, args.size()) + "]";
        else if (name.contains("this.fSEQX")) return "SEQX(" + argsText + ")";
        else if (name.contains("this.aGet") || name.contains("this.op_aGet")) return args.get(0) + "(" + sliceJoin(", ", args, 1, args.size()) + ")";
        else if (name.contains("this.INSERT__I__")) return "$INSERT I_" + split(name.trim(), "this.INSERT__I__").get(split(name.trim(), "this.INSERT__I__").size() - 1).trim().replace("_", ".");
        return deepest;
    }

    public static String handleReturns(String javaCode) {
        String out = javaCode;
        String[][] patterns = {
                {"\\s*this\\._Sys_ReturnTo \\= \\-[0-9];\\s*return \\-[0-9];\\s*RETURN", "\n%sRETURN"},
                {"\\s*this\\._Sys_ReturnTo \\= \\-[0-9];\\s*return \\-[0-9];\\s*END", "\n%sRETURN\n%sEND"},
                {"\\s*this\\._Sys_ReturnTo \\= \\-[0-9];\\s*return \\-[0-9];\\s*\\}", "\n%sRETURN\n%sEND"},
                {"\\s*return \\-[0-9];\\s*\\}", "\n%sRETURN\n%sEND"},
                {"\\s*return \\-[0-9];", "\n%sRETURN"}
        };
        for (String[] pair : patterns) {
            List<String> found = findAll(pair[0], out);
            Collections.sort(found);
            for (String f : found) {
                String last = split(f.trim(), "\n").get(split(f.trim(), "\n").size() - 1);
                String indent = last.startsWith(last.trim()) ? "" : last.substring(0, last.indexOf(last.trim()));
                out = out.replace(f, String.format(pair[1], indent, indent));
            }
        }
        return out;
    }

    public static String handleIfElseStatements(String javaCode) {
        String out = javaCode;
        List<String> breakPatterns = findAll("\\sif\\s*\\(\\!*this.boolVal\\(.*\\)\\)\\s*break\\s*\\;", out);
        Collections.sort(breakPatterns);
        for (String found : breakPatterns) {
            String indent = found.substring(0, found.indexOf(found.trim()));
            String replacement;
            if (found.contains("!this.boolVal")) {
                String args = String.join(",", extractMethodArguments(found, "!this.boolVal"));
                replacement = indent + "IF NOT(" + args + ") THEN BREAK;";
            } else {
                String args = String.join(",", extractMethodArguments(found, "this.boolVal"));
                replacement = indent + "IF " + args + " THEN BREAK;";
            }
            out = out.replace(found, replacement);
        }
        List<String> gotoPatterns = findAll("\\n\\s*if\\s*\\(\\!*this.boolVal\\(.*\\)\\)\\s*GOTO\\s*BLOCK[0-9]*;", out);
        Collections.sort(gotoPatterns);
        for (String found : gotoPatterns) {
            String replacement;
            if (found.contains("!this.boolVal")) {
                String args = String.join(",", extractMethodArguments(found, "!this.boolVal"));
                replacement = found.replace("if (!this.boolVal(" + args + "))", "IF NOT(" + args + ") THEN");
            } else {
                String args = String.join(",", extractMethodArguments(found, "this.boolVal"));
                replacement = found.replace("if (this.boolVal(" + args + "))", "IF " + args + " THEN");
            }
            out = out.replace(found, replacement);
        }
        List<String> ifPatterns = findAll("\\n\\s*if\\s*\\(\\!*this.boolVal\\(.*\\)\\)\\s*\\{", out);
        Collections.sort(ifPatterns);
        for (String found : ifPatterns) {
            String method = join("\n", methodExtractor(out, found));
            if (method.isEmpty()) continue;
            String firstLine = "";
            for (String l : split(found, "\n")) if (l.contains(" if ")) { firstLine = l; break; }
            String indent = firstLine.isEmpty() || firstLine.startsWith(firstLine.trim()) ? "" : firstLine.substring(0, firstLine.indexOf(firstLine.trim()));
            String to = method.replace(" if(", " if (");
            List<String[]> replacements = new ArrayList<>();
            for (String l : split(found, "\n")) {
                if (l.contains("!this.boolVal(")) {
                    String args = String.join(",", extractMethodArguments(l, "!this.boolVal"));
                    replacements.add(new String[]{"(!this.boolVal(" + args + "))", "NOT(" + convertJavaToJbcStandards(args) + ")"});
                }
                if (l.contains("this.boolVal(")) {
                    String args = String.join(",", extractMethodArguments(l, "this.boolVal"));
                    replacements.add(new String[]{"(this.boolVal(" + args + "))", convertJavaToJbcStandards(args)});
                }
            }
            for (String[] replacement : replacements) to = to.replace(replacement[0], replacement[1]);
            if (to.contains("} else if ")) {
                to = to.replace("\n" + indent + "} else if ", "\n" + indent + "CASE ")
                        .replace("\n" + indent + "if ", "\n" + indent + "CASE ")
                        .replace("\n" + indent + "} else {", "\n" + indent + "CASE 0:");
                to = sliceJoin("}", split(to, "}"), 0, split(to, "}").size() - 1);
                to = "\n" + indent + "BEGIN CASE\n" + to + "\n" + indent + "END CASE\n";
            } else if (to.contains("} else {")) {
                to = to.replace("\n" + indent + "} else {", "\n" + indent + "END ELSE");
                to = sliceJoin("}", split(to, "}"), 0, split(to, "}").size() - 1) + "END";
            } else {
                to = sliceJoin("}", split(to, "}"), 0, split(to, "}").size() - 1) + "END";
            }
            for (String caseLine : findAll("\\s+CASE\\s+.*\\s\\{", to)) {
                String caseHeader = caseLine.substring(0, caseLine.length() - 1).trim();
                String caseCondition = caseHeader.substring("CASE ".length()).trim();
                if (caseCondition.startsWith("(this.boolVal(")) {
                    caseHeader = "CASE " + String.join(",", extractMethodArguments(caseCondition, "this.boolVal")).trim();
                } else if (caseCondition.startsWith("(!this.boolVal(")) {
                    caseHeader = "CASE NOT(" + String.join(",", extractMethodArguments(caseCondition, "!this.boolVal")).trim() + ")";
                }
                while (caseHeader.endsWith(")") && count(caseHeader, "(") < count(caseHeader, ")")) {
                    caseHeader = caseHeader.substring(0, caseHeader.length() - 1).trim();
                }
                String caseIndent = caseLine.substring(0, caseLine.indexOf(caseLine.trim()));
                to = to.replace(caseLine, caseIndent + caseHeader + ":");
            }
            to = to.replace("\n" + indent + "if ", "\n" + indent + "IF ");
            for (String ifLine : findAll("\\s+IF\\s+.*\\s\\{", to)) to = to.replace(ifLine, ifLine.substring(0, ifLine.length() - 1) + "THEN");
            out = out.replace(method, to);
        }
        return out;
    }

    public static String handleWhileStatements(String javaCode) {
        String out = javaCode;
        while (out.contains(" do {")) {
            List<String> loops = findAll("\\s*do\\s*\\{", out);
            if (loops.isEmpty()) break;
            boolean changed = false;
            for (String loop : loops) {
                String method = join("\n", methodExtractor(out, loop));
                if (method.isEmpty()) continue;
                List<String> arr = split(method, "\n");
                String first = "";
                for (String l : arr) if (!l.trim().isEmpty()) { first = l; break; }
                String indent = first.startsWith(first.trim()) ? "" : first.substring(0, first.indexOf(first.trim()));
                String to = method;
                for (String wf : findAll("\\s*if\\s*\\(this\\._isBreak_\\s*\\|\\|\\s*\\!this\\.boolVal\\(.*\\)\\)\\s*break;", method)) {
                    String args = convertJavaFunctionsToJbc(String.join(",", extractMethodArguments(method, wf.split("!this.boolVal")[0].split("\n")[wf.split("!this.boolVal")[0].split("\n").length - 1] + "!this.boolVal"))).trim();
                    if (args.startsWith("READNEXT") && args.endsWith("EQ 0")) args = args.substring(0, args.length() - 4) + "DO";
                    to = to.replace(wf, "\n" + indent + "WHILE " + args);
                }
                for (String nwf : findAll("\\s*if\\s*\\(this\\._isBreak_\\s*\\|\\|\\s*this\\.boolVal\\(.*\\)\\)\\s*break;", method)) {
                    String args = convertJavaFunctionsToJbc(String.join(",", extractMethodArguments(method, nwf.split("this.boolVal")[0].split("\n")[nwf.split("this.boolVal")[0].split("\n").length - 1] + "this.boolVal"))).trim();
                    args = args.startsWith("READNEXT") && args.endsWith("EQ 0") ? args.substring(0, args.length() - 4) + ") DO" : args + ")";
                    to = to.replace(nwf, "\n" + indent + "WHILE NOT(" + args);
                }
                to = to.replace(loop, "\n" + indent + "LOOP");
                to = sliceJoin("}", split(to, "}"), 0, split(to, "}").size() - 1) + "REPEAT";
                out = out.replace(method, to);
                changed = true;
            }
            if (!changed) break;
        }
        return out;
    }

    public static String handleUnwantedStatements(String javaCode) {
        Encoded enc = encodeString(javaCode);
        String out = enc.text;
        String[][] patterns = {
                {"\\s\\w*\\.*\\_isContinue\\_\\s*\\=\\s*true\\s*;\\s+break\\s*;", " CONTINUE;"},
                {"\\s\\w*\\.*\\_isContinue\\_\\s*\\=\\s*true\\s*;", " CONTINUE;"},
                {"\\sbreak\\s*;", " BREAK;"},
                {"\\s+jVar\\s*\\w+[0-9]*\\s*\\=\\s*jVarFactory\\.get\\(\\(\\w+\\).*\\);", ""},
                {"\\n\\s+//.*", ""},
                {"\\s*long\\s*\\w+.*;", ""},
                {"\\s+this\\._[a-z]\\w+_\\s*\\=.*;", ""},
                {"\\s+if\\s*\\(this\\._[a-z]\\w+_\\)\\s*.*;", ""},
                {";\\s*;", ";"},
                {";+", ";"},
                {"\\s+jVar\\s+jVar[0-9];", ""},
                {"\\s+jVar[0-9]*\\s*\\=.*;", ""},
                {"\\s+jVar", ""},
                {"\\s+if\\s*\\(this\\._\\w+_\\)\\s*.*;", ""},
                {"\\s+IF\\s*\\(this\\._\\w+_\\)\\s*.*;", ""},
                {"\\n\\s+[a-z]\\w+\\s*;", "\n"},
                {"\\s+[a-z]\\w*\\s*\\=\\s*true\\s*;", ""},
                {"\\s+[a-z]\\w*\\s*\\=\\s*false\\s*;", ""},
                {"\\s+[a-z]\\w*\\s*\\=.*\\s*;*\\s+[a-z]\\w*\\s*\\=\\s*inc2\\(.*\\);*", ""},
                {"\\s+\\w+\\s*\\=\\s*.*\\s*;*\\s+\\w+\\s*\\=\\s*inc\\(.*\\);*", ""},
                {"\\s+[a-z]\\w*\\s*\\=\\s*inc2\\(.*\\);*", ""},
                {"\\s+\\w+\\s*\\=\\s*inc\\(.*\\);*", ""},
                {"\\s+\\w*\\s*\\=\\s*.*\\s*;*\\s+\\w*\\s*\\=\\s*inc2\\(.*\\);*", ""},
                {"\\s+\\w+\\.inc[0-9]*\\(.*\\);*", ""},
                {"\\s+var[0-9]+\\_[0-9]+\\s*\\=\\s*Factory\\.get\\(.*\\);", ""},
                {"\\s+this\\.INSERT__[^I]\\w+\\(.*\\)\\s*;", ""},
                {"\\s+return\\s+.*;", ""},
                {"\\sTHEN\\s*END\\s*ELSE", " ELSE"},
                {"\\s+\\w+\\s*int\\s*main\\s*\\(.*\\)\\s*\\{", ""},
                {"\\n\\s+this\\.get[A-Z]+_\\w+\\(\\)\\s*;", ""},
                {"\\s+component_[A-Z]+_\\w+_[0-9]+_cl\\s*component_[A-Z]+_\\w+_[0-9]+_cl[0-9]*\\s*\\=\\s*this\\.get[A-Z]+_\\w+\\(\\)\\s*;", ""},
                {"\\s+\\w[\\.\\w]*\\.inc[0-9]*\\(\\);", ""},
                {"jAtVariable\\.", "@"},
                {"this\\.positionScreenAt", "@"},
                {"this\\.fCHARX\\(", "CHARX("}
        };
        for (String found : findAll("\\s+Object\\[\\]\\s+objectArray[0-9]*\\s*\\=\\s*new\\s+Object\\[[0-9]+\\];\\s+objectArray[0-9]*\\[[0-9]+\\]\\s*\\=\\s*.*;\\s+.*R\\.NEW\\(objectArray[0-9]*\\).*", out)) {
            List<String> lines = split(found, "\n");
            if (lines.size() >= 2) {
                String field = split(split(lines.get(lines.size() - 2), "=").get(split(lines.get(lines.size() - 2), "=").size() - 1), ";").get(0);
                String arrayName = split(split(lines.get(lines.size() - 2), "=").get(0), "[").get(0).trim();
                out = out.replace(found, "\n" + lines.get(lines.size() - 1).replace("(" + arrayName + ")", "(" + field + ")"));
            }
        }
        for (String found : findAll("\\s+if\\s*\\(.*\\)\\s*\\*\\*\\s*GOTO\\s*\\w+[0-9]+", out)) {
            out = out.replace(found, found.replace(" if ", " IF ").replace(" ** ", " THEN "));
        }
        for (String[] p : patterns) for (String f : uniqueSortedFindAll(p[0], out)) out = out.replace(f, p[1]);
        String[][] objectPatterns = {
                {"new Object\\[\\]\\{\\w+\\}", "{", "}", "", ""},
                {"new Object\\[\\]\\{.*\\}", "{", "}", "", ""},
                {"\\s*Factory\\.get\\(\\(\\w+\\).*?\\);", ")", ")", "", ""},
                {"new jPosition\\(.*\\)", "(", ")", "[", "]"}
        };
        for (String[] p : objectPatterns) for (String f : uniqueSortedFindAll(p[0], out)) {
            List<String> a = split(f, p[1]);
            String mid = a.size() > 1 ? split(a.get(1), p[2]).get(0) : "";
            out = out.replace(f, p[3] + mid + p[4]);
        }
        out = decodeString(out, enc.map);
        for (String f : uniqueSortedFindAll("new PreciseDecimal\\(\".*\"\\)", out)) out = out.replace(f, split(split(f, "(\"").get(1), "\")").get(0));
        return out;
    }

    public static String handleLineNumbers(String javaCode) {
        String out = javaCode;
        for (String f : uniqueSortedFindAll("\\s*this\\._l\\(.*\\);", out)) out = out.replace(f, "");
        return out;
    }

    public static String componentToInfobasicStandard(String varName) {
        StringBuilder b = new StringBuilder();
        for (char c : varName.toCharArray()) {
            if (Character.toLowerCase(c) != c) b.append(' ');
            b.append(c);
        }
        return b.toString().trim().replace(" ", ".").toUpperCase();
    }

    public static String handleComponentMethodDeclaration(String javaCode) {
        List<String> entries = new ArrayList<>();
        Map<String, String> componentMap = new LinkedHashMap<>();
        String packName = "";
        for (String found : uniqueSortedFindAll("jRunTime\\.logComponentUsage\\(\\(jSession\\)this\\.session\\,.*\\(String\\)\"METHOD\"\\,.*\\);", javaCode)) {
            List<String> q = split(found, "\"");
            if (q.size() > 7) {
                packName = q.get(1);
                String comp = q.get(5);
                String rtn = q.get(7);
                entries.add("public method " + comp + "()\n{\n\tjBC: " + rtn + "\n}");
                componentMap.put(comp, rtn);
            }
        }
        Map<String, List<String[]>> tableMap = new LinkedHashMap<>();
        for (String found : uniqueSortedFindAll("\\sint\\s+_\\w+_\\w+\\s*\\=\\s*null\\s*\\!\\=\\s*null\\s*\\?\\s*[0-9]+\\s*\\:\\s*[0-9]+;", javaCode)) {
            List<String> u = split(found, "_");
            if (u.size() >= 3) {
                String table = u.get(1);
                String field = split(u.get(2), "=").get(0).trim();
                String pos = split(split(found, ":").get(split(found, ":").size() - 1), ";").get(0).trim();
                String mapName = table.endsWith("Table") ? table.substring(0, table.length() - 5) : table;
                String t24 = componentMap.getOrDefault(mapName, "");
                tableMap.computeIfAbsent(table, k -> new ArrayList<>()).add(new String[]{t24, field + "(" + componentToInfobasicStandard(field) + ") = " + pos});
            }
        }
        List<String> tableCodes = new ArrayList<>();
        for (Map.Entry<String, List<String[]>> e : tableMap.entrySet()) {
            StringBuilder b = new StringBuilder("public table " + e.getKey() + " {\n\tt24: " + e.getValue().get(0)[0] + "\n\tfields: {\n");
            for (String[] row : e.getValue()) b.append("\t\t").append(row[1]).append("\n");
            b.append("\t\t}\n}");
            tableCodes.add(b.toString());
        }
        return "component " + packName + "\nmetamodelVersion 1.6\n\n" + join("\n", entries) + "\n\n" + join("\n", tableCodes);
    }

    public static String handleUnwantedIfStatements(String javaCode) {
        String out = javaCode;
        String[][] patterns = {
                {"\\n\\s*if\\s*\\(\\!this\\._[a-z]\\w+_\\)\\s*\\{", null},
                {"\\n\\s*if\\s*\\(this\\._[a-z]\\w+_\\)\\s*\\{", null},
                {"\\n\\s*if\\s*\\(this\\._[a-z]\\w+_\\)\\s*\\w+\\s*;", ""},
                {"\\n\\s*if\\s*\\(\\!this\\._[a-z]\\w+_\\)\\s*\\w+\\s*;", ""}
        };
        for (String[] p : patterns) {
            for (String f : uniqueSortedFindAll(p[0], out)) {
                if (p[1] == null) {
                    String indent = f.substring(1, f.indexOf(f.trim()));
                    out = out.replace(f, "").replace(indent + "}", "");
                } else out = out.replace(f, p[1]);
            }
        }
        return out;
    }

    public static String getUsingStatements(String javaCode, int indent) {
        String prefix = repeat(" ", indent);
        List<String> using = new ArrayList<>();
        for (String found : findAll("import\\s*com\\.temenos\\.t24\\.component_[A-Z]+_\\w+_[0-9]+_cl;", javaCode)) {
            List<String> dots = split(found, ".");
            List<String> parts = split(dots.get(dots.size() - 1), "_");
            using.add(prefix + "$USING " + sliceJoin(".", parts, 1, parts.size() - 2));
        }
        return join("\n", using);
    }

    public static void decompileJar(String jarPath, String outputDir, String cfrJarPath) throws IOException, InterruptedException {
        Files.createDirectories(Paths.get(outputDir));
        ProcessBuilder pb = new ProcessBuilder("java", "-jar", cfrJarPath, jarPath, "--outputdir", outputDir);
        pb.inheritIO();
        Process p = pb.start();
        int exit = p.waitFor();
        if (exit != 0) throw new IOException("CFR decompile failed with exit code " + exit);
    }

    public static List<Path> iterateFilesInFolder(String folderPath, String extension) throws IOException {
        List<Path> out = new ArrayList<>();
        try (Stream<Path> stream = Files.walk(Paths.get(folderPath))) {
            stream.filter(Files::isRegularFile)
                    .filter(p -> extension == null || p.toString().toLowerCase().endsWith(extension.toLowerCase()))
                    .forEach(out::add);
        }
        out.sort(Comparator.comparing(Path::toString));
        return out;
    }

    public static Map<String, String> generateLineNumberMapping(String code) {
        Map<String, String> map = new LinkedHashMap<>();
        List<String> pieces = split(code, "this._l(");
        for (int i = 1; i < pieces.size(); i++) {
            String line = pieces.get(i);
            String num = split(split(split(line, ";").get(0), ",").get(0), ")").get(0).trim();
            List<String> semi = split(line, ";");
            map.put(num, sliceJoin(";", semi, 1, semi.size()));
        }
        return map;
    }

    private static String csv(String s) {
        return "\"" + s.replace("\"", "\"\"") + "\"";
    }

    public static void main(String[] args) throws Exception {
        String decompileDir = args.length > 0 ? args[0] : ".\\JavaCodeBase_ATIB_component\\";
        String jarFile = args.length > 1 ? args[1] : "C:\\Goutham\\DXC-Products\\infobasic_src_reconstruct\\ATIB\\SERVER-31\\JARS\\OTHERLIB\\ATIB_component.jar";
        String outputDir = args.length > 2 ? args[2] : ".\\ReconstructedRoutines_ATIB_component\\";
        String cfrJar = args.length > 3 ? args[3] : "C:\\Goutham\\DXC-Products\\infobasic_src_reconstruct\\cfr\\cfr-0.152.jar";
        boolean decompile = args.length > 4 && "--decompile".equalsIgnoreCase(args[4]);
        if (decompile) decompileJar(jarFile, decompileDir, cfrJar);

        Files.createDirectories(Paths.get(decompileDir));
        Files.createDirectories(Paths.get(outputDir));
        Path index = Paths.get(decompileDir, "RoutineReconstructIndex.csv");
        try (BufferedWriter indexOut = Files.newBufferedWriter(index, StandardCharsets.UTF_8)) {
            indexOut.write("JAR.NAME,ROUTINE.NAME,JAVA.LINE.NUMBER,JAVA.CODE,JBC.CODE");
        }

        String watermark = "\n*=================================================\n*Reconstructed from class file by DXC Luxoft\n*=================================================\n";
        for (Path filePath : iterateFilesInFolder(decompileDir, "java")) {
            System.out.print("\rRoutine Generation Initiated For \"" + filePath + "\"..");
            String javaCode = Files.readString(filePath, StandardCharsets.UTF_8);
            String fileName = filePath.getFileName().toString();
            String subroutineNameFileName = "";
            String checkPointCode = "";
            String newJavaCode = "";
            try {
                if (fileName.startsWith("component_")) {
                    newJavaCode = handleComponentMethodDeclaration(javaCode);
                    List<String> parts = split(fileName, "_");
                    subroutineNameFileName = sliceJoin(".", parts, 1, parts.size() - 2) + ".component";
                    checkPointCode = newJavaCode;
                } else {
                    String subroutineName = "";
                    String subroutineArguments = "";
                    if (javaCode.contains("this.invokeRestart(") && split(javaCode, "this.invokeRestart(").size() > 1 && split(javaCode, "this.invokeRestart(").get(1).contains("\"")) {
                        subroutineName = split(split(javaCode, "this.invokeRestart(").get(1), "\"").get(1);
                        if (subroutineName.length() >= 3) subroutineName = subroutineName.substring(0, subroutineName.length() - 3);
                        subroutineName = subroutineName.replace("_", ".").replace("..", "_");
                    }
                    subroutineNameFileName = subroutineName + ".b";
                    if (javaCode.contains("this.invokeRestart(")) {
                        String after = split(javaCode, "this.invokeRestart(").get(1);
                        if (split(after, "\n").get(0).contains("}")) subroutineArguments = "(" + convertJavaToJbcStandards(split(split(after, "}").get(0), "{").get(split(split(after, "}").get(0), "{").size() - 1)) + ")";
                    }
                    String using = getUsingStatements(javaCode, 4);
                    newJavaCode = handleSwitchFunction(handleForLoops(handleInserts(methodCallsToCallStmts(methodNamesToGosubLabels(handleGosubs(getJbcCode(javaCode)))))));
                    newJavaCode = handleWhileStatements(newJavaCode);
                    newJavaCode = handleIfElseStatements(newJavaCode);
                    newJavaCode = handleReturns(newJavaCode);
                    List<String> converted = new ArrayList<>();
                    for (String line : split(newJavaCode, "\n")) converted.add(convertJavaToJbcStandards(convertJavaFunctionsToJbc(line, true)));
                    newJavaCode = join("\n", converted);
                    newJavaCode = handleUnwantedIfStatements(newJavaCode);
                    checkPointCode = watermark + "\nSUBROUTINE " + subroutineName + subroutineArguments + "\n" + newJavaCode + "\n********************";
                    newJavaCode = handleUnwantedStatements(newJavaCode);
                    String indexFileCode = newJavaCode;
                    newJavaCode = handleLineNumbers(newJavaCode);
                    newJavaCode = watermark + "\nSUBROUTINE " + subroutineName + subroutineArguments + "\n" + using + "\n" + newJavaCode + "\n********************";

                    Map<String, String> javaMap = generateLineNumberMapping(getJbcCode(javaCode));
                    Map<String, String> processedMap = generateLineNumberMapping(indexFileCode);
                    try (BufferedWriter indexAp = Files.newBufferedWriter(index, StandardCharsets.UTF_8, java.nio.file.StandardOpenOption.APPEND)) {
                        for (Map.Entry<String, String> e : processedMap.entrySet()) {
                            String javaLine = javaMap.getOrDefault(e.getKey(), "");
                            String javaStd = convertJavaToJbcStandards(javaLine);
                            String processed = e.getValue();
                            if (processed.trim().equals(javaStd.trim()) && !processed.trim().isEmpty() && !processed.trim().contains("=")) {
                                indexAp.write("\n" + csv(Paths.get(jarFile).getFileName().toString()) + "," + csv(subroutineName) + "," + csv(e.getKey()) + "," + csv(javaLine) + "," + csv(processed));
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                System.out.println("\n\n\n** ERROR ** Generation Failed \"" + filePath + "\"");
                ex.printStackTrace(System.out);
            }
            if (!subroutineNameFileName.isEmpty()) {
                Files.writeString(Paths.get(decompileDir, subroutineNameFileName + ".checkpoint"), checkPointCode, StandardCharsets.UTF_8);
                Files.writeString(Paths.get(outputDir, subroutineNameFileName), newJavaCode, StandardCharsets.UTF_8);
            }
        }
    }
}
