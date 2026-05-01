const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, HeadingLevel, BorderStyle, WidthType,
  ShadingType, PageNumber, PageBreak, LevelFormat,
} = require("docx");

// ========== HELPERS ==========
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };
const headerBorder = { style: BorderStyle.SINGLE, size: 1, color: "1B5E6B" };
const headerBorders = { top: headerBorder, bottom: headerBorder, left: headerBorder, right: headerBorder };
const cellMargins = { top: 60, bottom: 60, left: 100, right: 100 };

const COL_NO = 600;
const COL_METHOD = 900;
const COL_ENDPOINT = 3200;
const COL_DESC = 2400;
const COL_AUTH = 900;
const TABLE_W = COL_NO + COL_METHOD + COL_ENDPOINT + COL_DESC + COL_AUTH;

const COL_FIELD = 2000;
const COL_TYPE = 1200;
const COL_REQ = 900;
const COL_FDESC = 4260;
const FIELD_TABLE_W = COL_FIELD + COL_TYPE + COL_REQ + COL_FDESC;

function headerCell(text, width) {
  return new TableCell({
    borders: headerBorders,
    width: { size: width, type: WidthType.DXA },
    shading: { fill: "1B5E6B", type: ShadingType.CLEAR },
    margins: cellMargins,
    verticalAlign: "center",
    children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text, bold: true, color: "FFFFFF", font: "Arial", size: 18 })] })],
  });
}

function cell(text, width, opts = {}) {
  const runs = [new TextRun({ text, font: "Arial", size: 18, bold: opts.bold || false, color: opts.color || "333333" })];
  return new TableCell({
    borders,
    width: { size: width, type: WidthType.DXA },
    shading: opts.fill ? { fill: opts.fill, type: ShadingType.CLEAR } : undefined,
    margins: cellMargins,
    children: [new Paragraph({ alignment: opts.align || AlignmentType.LEFT, children: runs })],
  });
}

function fieldHeaderCell(text, width) {
  return new TableCell({
    borders: headerBorders,
    width: { size: width, type: WidthType.DXA },
    shading: { fill: "2E7D8C", type: ShadingType.CLEAR },
    margins: cellMargins,
    children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text, bold: true, color: "FFFFFF", font: "Arial", size: 17 })] })],
  });
}

function fieldCell(text, width, opts = {}) {
  return new TableCell({
    borders,
    width: { size: width, type: WidthType.DXA },
    shading: opts.fill ? { fill: opts.fill, type: ShadingType.CLEAR } : undefined,
    margins: cellMargins,
    children: [new Paragraph({ children: [new TextRun({ text, font: "Consolas", size: 17, color: opts.color || "333333", bold: opts.bold })] })],
  });
}

function apiRow(no, method, endpoint, desc, auth, rowFill) {
  const mColor = method === "GET" ? "2E7D32" : method === "POST" ? "1565C0" : method === "PUT" ? "F57F17" : method === "DELETE" ? "C62828" : "333333";
  return new TableRow({
    children: [
      cell(no, COL_NO, { align: AlignmentType.CENTER, fill: rowFill }),
      cell(method, COL_METHOD, { bold: true, color: mColor, align: AlignmentType.CENTER, fill: rowFill }),
      cell(endpoint, COL_ENDPOINT, { fill: rowFill }),
      cell(desc, COL_DESC, { fill: rowFill }),
      cell(auth, COL_AUTH, { align: AlignmentType.CENTER, fill: rowFill }),
    ],
  });
}

function sectionHeading(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 360, after: 160 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: 26, color: "1B5E6B" })],
  });
}

function subHeading(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 240, after: 100 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: 22, color: "2E7D8C" })],
  });
}

function bodyText(text) {
  return new Paragraph({
    spacing: { after: 80 },
    children: [new TextRun({ text, font: "Arial", size: 20, color: "444444" })],
  });
}

function apiTable(rows) {
  return new Table({
    width: { size: TABLE_W, type: WidthType.DXA },
    columnWidths: [COL_NO, COL_METHOD, COL_ENDPOINT, COL_DESC, COL_AUTH],
    rows: [
      new TableRow({ children: [headerCell("#", COL_NO), headerCell("Method", COL_METHOD), headerCell("Endpoint", COL_ENDPOINT), headerCell("Description", COL_DESC), headerCell("Auth", COL_AUTH)] }),
      ...rows,
    ],
  });
}

function fieldTable(fields) {
  return new Table({
    width: { size: FIELD_TABLE_W, type: WidthType.DXA },
    columnWidths: [COL_FIELD, COL_TYPE, COL_REQ, COL_FDESC],
    rows: [
      new TableRow({ children: [fieldHeaderCell("Field", COL_FIELD), fieldHeaderCell("Type", COL_TYPE), fieldHeaderCell("Required", COL_REQ), fieldHeaderCell("Description", COL_FDESC)] }),
      ...fields.map((f, i) => {
        const fill = i % 2 === 0 ? "F8FAFA" : undefined;
        return new TableRow({
          children: [
            fieldCell(f[0], COL_FIELD, { fill, bold: true }),
            fieldCell(f[1], COL_TYPE, { fill }),
            fieldCell(f[2], COL_REQ, { fill }),
            fieldCell(f[3], COL_FDESC, { fill }),
          ],
        });
      }),
    ],
  });
}

function detailBlock(title, method, endpoint, reqFields, resFields, notes) {
  const items = [
    subHeading(title),
    bodyText(`${method} ${endpoint}`),
  ];
  if (reqFields && reqFields.length > 0) {
    items.push(new Paragraph({ spacing: { before: 120, after: 60 }, children: [new TextRun({ text: "Request:", bold: true, font: "Arial", size: 19, color: "1B5E6B" })] }));
    items.push(fieldTable(reqFields));
  }
  if (resFields && resFields.length > 0) {
    items.push(new Paragraph({ spacing: { before: 120, after: 60 }, children: [new TextRun({ text: "Response:", bold: true, font: "Arial", size: 19, color: "1B5E6B" })] }));
    items.push(fieldTable(resFields));
  }
  if (notes) {
    items.push(new Paragraph({ spacing: { before: 80, after: 80 }, children: [new TextRun({ text: `Note: ${notes}`, font: "Arial", size: 18, italics: true, color: "666666" })] }));
  }
  return items;
}

// ========== BUILD DOCUMENT ==========

const children = [];

// TITLE PAGE
children.push(new Paragraph({ spacing: { before: 3000 }, alignment: AlignmentType.CENTER, children: [] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 }, children: [new TextRun({ text: "MANDAL CAPITAL", font: "Arial", size: 44, bold: true, color: "1B5E6B" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [new TextRun({ text: "API Requirements Document", font: "Arial", size: 32, color: "2E7D8C" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 60 }, children: [new TextRun({ text: "API \u0428\u0430\u0430\u0440\u0434\u043B\u0430\u0433\u0430\u0442\u0430\u0439 \u0411\u0430\u0440\u0438\u043C\u0442 \u0411\u0438\u0447\u0438\u0433", font: "Arial", size: 24, color: "666666" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 600, after: 100 }, children: [new TextRun({ text: "Version 1.1", font: "Arial", size: 22, color: "999999" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "2026-04-01", font: "Arial", size: 22, color: "999999" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 1200 }, border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "1B5E6B", space: 1 } }, children: [] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200 }, children: [new TextRun({ text: "Base URL: https://31.220.72.239", font: "Consolas", size: 20, color: "1B5E6B" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [new TextRun({ text: "Content-Type: application/json", font: "Consolas", size: 20, color: "999999" })] }));
children.push(new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Authorization: Bearer {token}", font: "Consolas", size: 20, color: "999999" })] }));

children.push(new Paragraph({ children: [new PageBreak()] }));

// TABLE OF CONTENTS SECTION
children.push(new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 200, after: 300 }, children: [new TextRun({ text: "\u0410\u0433\u0443\u0443\u043B\u0433\u0430 / Table of Contents", font: "Arial", size: 30, bold: true, color: "1B5E6B" })] }));
const tocItems = [
  "1. \u041D\u044D\u0432\u0442\u0440\u044D\u043B\u0442 / Authentication (10 endpoints)",
  "2. OTP \u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442 / Verification (4 endpoints)",
  "3. KYC / \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447 \u0442\u0430\u043D\u0438\u043B\u0442 (6 endpoints)",
  "4. \u041D\u04AF\u04AF\u0440 \u0445\u0443\u0443\u0434\u0430\u0441 / Dashboard (5 endpoints)",
  "5. \u0411\u043E\u043D\u0434 / Bonds (10 endpoints)",
  "6. \u0425\u0443\u0432\u044C\u0446\u0430\u0430 / Stocks (13 endpoints)",
  "7. \u0417\u0430\u0445\u0438\u0430\u043B\u0433\u0430 \u0431\u0430 \u0413\u04AF\u0439\u043B\u0433\u044D\u044D / Orders & Transactions (6 endpoints)",
  "8. \u041C\u04E9\u043D\u0433\u04E9\u043D \u0443\u0434\u0438\u0440\u0434\u043B\u0430\u0433\u0430 / Cash Management (9 endpoints)",
  "9. Watchlist (4 endpoints)",
  "10. \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B / User & Notifications (7 endpoints)",
  "11. \u0425\u0430\u0434\u0433\u0430\u043B\u0430\u043C\u0436 / Savings (2 endpoints)",
];
tocItems.forEach(t => {
  children.push(new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: t, font: "Arial", size: 21, color: "444444" })] }));
});
children.push(new Paragraph({ spacing: { before: 200 }, children: [new TextRun({ text: "\u041D\u0438\u0439\u0442: 76 API endpoint", font: "Arial", size: 20, bold: true, color: "1B5E6B" })] }));

children.push(new Paragraph({ children: [new PageBreak()] }));

// ========== 1. AUTHENTICATION ==========
children.push(sectionHeading("1. \u041D\u044D\u0432\u0442\u0440\u044D\u043B\u0442 / Authentication"));
children.push(bodyText("\u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D \u043D\u044D\u0432\u0442\u0440\u044D\u043B\u0442, \u0431\u04AF\u0440\u0442\u0433\u044D\u043B, \u043D\u0443\u0443\u0446 \u04AF\u0433, \u0442\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436\u0438\u0439\u043D \u0431\u04AF\u0440\u0442\u0433\u044D\u043B, \u0431\u0438\u043E\u043C\u0435\u0442\u0440\u0438\u043A \u043D\u044D\u0432\u0442\u0440\u044D\u043B\u0442\u0442\u044D\u0439 \u0445\u043E\u043B\u0431\u043E\u043E\u0442\u043E\u0439 endpoint-\u0443\u0443\u0434."));

// Flow diagram as text
children.push(new Paragraph({ spacing: { before: 200, after: 60 }, children: [new TextRun({ text: "Login Flow:", bold: true, font: "Arial", size: 20, color: "1B5E6B" })] }));
children.push(bodyText("1. login(userName, userPass, deviceId) \u2192 code \"0\": deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0442\u044D\u0439 \u2192 \u0448\u0443\u0443\u0434 token"));
children.push(bodyText("2. login(...) \u2192 code \"2\": deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0433\u04AF\u0439 \u2192 sessionId \u0431\u0443\u0446\u0430\u0430\u043D\u0430 \u2192 OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445"));
children.push(bodyText("3. OTP \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439 \u2192 register_device(sessionId, deviceId) \u2192 token + deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u0433\u0434\u044D\u043D\u044D"));
children.push(bodyText("4. biometric_login(deviceId, uid) \u2192 \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0442\u044D\u0439 deviceId \u0448\u0430\u0430\u0440\u0434\u043B\u0430\u0433\u0430\u0442\u0430\u0439"));
children.push(new Paragraph({ spacing: { after: 120 }, children: [] }));

children.push(apiTable([
  apiRow("1", "POST", "/bdc/api/auth/login.php", "\u041D\u044D\u0432\u0442\u0440\u044D\u0445 (api: login)", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("2", "POST", "/bdc/api/auth/login.php", "\u0411\u0438\u043E\u043C\u0435\u0442\u0440\u0438\u043A (api: biometric_login)", "\u04AE\u0433\u04AF\u0439", undefined),
  apiRow("3", "POST", "/bdc/api/auth/login.php", "Device \u0431\u04AF\u0440\u0442\u0433\u044D\u0445 (api: register_device)", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("4", "POST", "/bdc/api/auth/login.php", "Token \u0441\u044D\u0440\u0433\u044D\u044D\u0445 (api: refresh)", "Bearer", undefined),
  apiRow("5", "POST", "/bdc/api/auth/register/validate", "\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440 \u0448\u0430\u043B\u0433\u0430\u0445", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("6", "POST", "/bdc/api/auth/register/initiate", "\u0411\u04AF\u0440\u0442\u0433\u044D\u043B \u044D\u0445\u043B\u04AF\u04AF\u043B\u044D\u0445", "\u04AE\u0433\u04AF\u0439", undefined),
  apiRow("7", "POST", "/bdc/api/auth/register/set_password", "\u041D\u0443\u0443\u0446 \u04AF\u0433 \u0442\u043E\u0433\u0442\u043E\u043E\u0445", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("8", "POST", "/bdc/api/auth/register/add_account", "\u0414\u0430\u043D\u0441 \u0431\u04AF\u0440\u0442\u0433\u04AF\u04AF\u043B\u044D\u0445", "\u04AE\u0433\u04AF\u0439", undefined),
  apiRow("9", "POST", "/bdc/api/auth/forgot_password/initiate", "\u041D\u0443\u0443\u0446 \u04AF\u0433 \u0441\u044D\u0440\u0433\u044D\u044D\u0445 \u044D\u0445\u043B\u04AF\u04AF\u043B\u044D\u0445", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("10", "POST", "/bdc/api/auth/forgot_password/reset", "\u0428\u0438\u043D\u044D \u043D\u0443\u0443\u0446 \u04AF\u0433 \u0442\u043E\u0433\u0442\u043E\u043E\u0445", "\u04AE\u0433\u04AF\u0439", undefined),
]));

// Detail: Login with deviceId
children.push(...detailBlock(
  "1.1 \u041D\u044D\u0432\u0442\u0440\u044D\u0445 / Login",
  "POST", "/bdc/api/auth/login.php",
  [
    ["api", "string", "\u0422\u0438\u0439\u043C", "\"login\""],
    ["userName", "string", "\u0422\u0438\u0439\u043C", "\u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D \u043D\u044D\u0440 (\u0443\u0442\u0430\u0441/\u0438\u043C\u044D\u0439\u043B)"],
    ["userPass", "string", "\u0422\u0438\u0439\u043C", "\u041D\u0443\u0443\u0446 \u04AF\u0433"],
    ["deviceId", "string", "\u0422\u0438\u0439\u043C", "\u0422\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436\u0438\u0439\u043D UUID (UUID v4)"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439, \"2\" = OTP \u0448\u0430\u0430\u0440\u0434\u043B\u0430\u0433\u0430\u0442\u0430\u0439"],
    ["message", "string", "\u0422\u0438\u0439\u043C", "\u0425\u0430\u0440\u0438\u0443 \u043C\u0435\u0441\u0441\u0435\u0436"],
    ["data.token", "string", "code=0", "JWT access token"],
    ["data.refreshToken", "string", "code=0", "Refresh token"],
    ["data.sessionId", "string", "code=2", "OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442\u044B\u043D session ID"],
  ],
  "code \"0\": deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0442\u044D\u0439 \u2192 \u0448\u0443\u0443\u0434 token. code \"2\": deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0433\u04AF\u0439 \u2192 OTP \u0448\u0430\u0430\u0440\u0434\u043B\u0430\u0433\u0430\u0442\u0430\u0439. JWT token-\u0434 uid, custName, roles \u0430\u0433\u0443\u0443\u043B\u0430\u0433\u0434\u0430\u043D\u0430."
));

// Detail: Biometric Login
children.push(...detailBlock(
  "1.2 \u0411\u0438\u043E\u043C\u0435\u0442\u0440\u0438\u043A \u043D\u044D\u0432\u0442\u0440\u044D\u043B\u0442 / Biometric Login",
  "POST", "/bdc/api/auth/login.php",
  [
    ["api", "string", "\u0422\u0438\u0439\u043C", "\"biometric_login\""],
    ["deviceId", "string", "\u0422\u0438\u0439\u043C", "\u0411\u04AF\u0440\u0442\u0433\u044D\u043B\u0442\u044D\u0439 \u0442\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436\u0438\u0439\u043D UUID"],
    ["uid", "string", "\u0422\u0438\u0439\u043C", "\u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D UID (token-\u043E\u043E\u0441 \u0430\u0432\u0441\u0430\u043D)"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"],
    ["data.token", "string", "\u0422\u0438\u0439\u043C", "JWT access token"],
    ["data.refreshToken", "string", "\u0422\u0438\u0439\u043C", "Refresh token"],
  ],
  "Client \u0442\u0430\u043B: local_auth-\u0430\u0430\u0440 \u0445\u0443\u0440\u0443\u0443\u043D\u044B \u0445\u044D\u044D/\u043D\u04AF\u04AF\u0440 \u0442\u0430\u043D\u0438\u0445 \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0441\u043D\u044B \u0434\u0430\u0440\u0430\u0430 server-\u0442 \u0438\u043B\u0433\u044D\u044D\u043D\u044D. \u0417\u04E9\u0432\u0445\u04E9\u043D deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0442\u044D\u0439 \u04AF\u0435\u0434 \u043B \u0430\u0436\u0438\u043B\u043B\u0430\u043D\u0430."
));

// Detail: Register Device
children.push(...detailBlock(
  "1.3 \u0422\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436 \u0431\u04AF\u0440\u0442\u0433\u044D\u0445 / Register Device",
  "POST", "/bdc/api/auth/login.php",
  [
    ["api", "string", "\u0422\u0438\u0439\u043C", "\"register_device\""],
    ["sessionId", "string", "\u0422\u0438\u0439\u043C", "Login-\u0441 \u0431\u0443\u0446\u0441\u0430\u043D sessionId (OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0441\u043D\u044B \u0434\u0430\u0440\u0430\u0430)"],
    ["deviceId", "string", "\u0422\u0438\u0439\u043C", "\u0411\u04AF\u0440\u0442\u0433\u044D\u0445 \u0442\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436\u0438\u0439\u043D UUID"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"],
    ["data.token", "string", "\u0422\u0438\u0439\u043C", "JWT access token"],
    ["data.refreshToken", "string", "\u0422\u0438\u0439\u043C", "Refresh token"],
  ],
  "OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0441\u043D\u044B \u0434\u0430\u0440\u0430\u0430 \u0434\u0443\u0443\u0434\u043D\u0430. deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u0433\u0434\u0441\u044D\u043D\u044D\u044D\u0440 \u0434\u0430\u0440\u0430\u0430\u0433\u0438\u0439\u043D login-\u0434 OTP \u0448\u0430\u0430\u0440\u0434\u0430\u0445\u0433\u04AF\u0439, \u043C\u04E9\u043D biometric_login \u0430\u0448\u0438\u0433\u043B\u0430\u0445 \u0431\u043E\u043B\u043E\u043C\u0436\u0442\u043E\u0439 \u0431\u043E\u043B\u043D\u043E."
));

// Detail: Refresh
children.push(...detailBlock(
  "1.4 Token \u0441\u044D\u0440\u0433\u044D\u044D\u0445 / Refresh Token",
  "POST", "/bdc/api/auth/login.php",
  [
    ["api", "string", "\u0422\u0438\u0439\u043C", "\"refresh\""],
    ["refreshToken", "string", "\u0422\u0438\u0439\u043C", "\u0425\u0430\u0434\u0433\u0430\u043B\u0441\u0430\u043D refresh token"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"],
    ["data.token", "string", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043D\u044D JWT access token"],
    ["data.refreshToken", "string", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043D\u044D refresh token"],
  ],
  "Header-\u0442 Authorization: Bearer {expired_token} \u0438\u043B\u0433\u044D\u044D\u043D\u044D. 401 \u04AF\u0435\u0434 interceptor \u0430\u0432\u0442\u043E\u043C\u0430\u0442\u0430\u0430\u0440 \u0434\u0443\u0443\u0434\u043D\u0430."
));

// Detail: Register validate
children.push(...detailBlock(
  "1.5 \u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440 \u0448\u0430\u043B\u0433\u0430\u0445",
  "POST", "/bdc/api/auth/register/validate",
  [
    ["registerNumber", "string", "\u0422\u0438\u0439\u043C", "\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440 (\u0423\u041F12345678)"],
    ["phone", "string", "\u0422\u0438\u0439\u043C", "\u0423\u0442\u0430\u0441\u043D\u044B \u0434\u0443\u0433\u0430\u0430\u0440"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0431\u0430\u0439\u0445\u0433\u04AF\u0439, \u0431\u04AF\u0440\u0442\u0433\u04AF\u04AF\u043B\u0436 \u0431\u043E\u043B\u043D\u043E"],
    ["message", "string", "\u0422\u0438\u0439\u043C", "\u0410\u043B\u0434\u0430\u0430\u043D\u044B \u043C\u0435\u0441\u0441\u0435\u0436"],
  ], null
));

children.push(...detailBlock(
  "1.6 \u0411\u04AF\u0440\u0442\u0433\u044D\u043B \u044D\u0445\u043B\u04AF\u04AF\u043B\u044D\u0445",
  "POST", "/bdc/api/auth/register/initiate",
  [
    ["registerNumber", "string", "\u0422\u0438\u0439\u043C", "\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440"],
    ["phone", "string", "\u0422\u0438\u0439\u043C", "\u0423\u0442\u0430\u0441\u043D\u044B \u0434\u0443\u0433\u0430\u0430\u0440"],
    ["lastName", "string", "\u0422\u0438\u0439\u043C", "\u041E\u0432\u043E\u0433"],
    ["firstName", "string", "\u0422\u0438\u0439\u043C", "\u041D\u044D\u0440"],
  ],
  [
    ["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"],
    ["data.sessionId", "string", "\u0422\u0438\u0439\u043C", "\u0411\u04AF\u0440\u0442\u0433\u044D\u043B\u0438\u0439\u043D session ID"],
  ], null
));

children.push(...detailBlock("1.7 \u041D\u0443\u0443\u0446 \u04AF\u0433 \u0442\u043E\u0433\u0442\u043E\u043E\u0445", "POST", "/bdc/api/auth/register/set_password",
  [["sessionId", "string", "\u0422\u0438\u0439\u043C", "Session"], ["password", "string", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043D\u044D \u043D\u0443\u0443\u0446 \u04AF\u0433"], ["confirmPassword", "string", "\u0422\u0438\u0439\u043C", "\u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"]], null));

children.push(...detailBlock("1.8 \u0411\u04AF\u0440\u0442\u0433\u044D\u043B\u0434 \u0434\u0430\u043D\u0441 \u043D\u044D\u043C\u044D\u0445", "POST", "/bdc/api/auth/register/add_account",
  [["sessionId", "string", "\u0422\u0438\u0439\u043C", "Session"], ["bankCode", "string", "\u0422\u0438\u0439\u043C", "\u0411\u0430\u043D\u043A\u043D\u044B \u043A\u043E\u0434"], ["iban", "string", "\u0422\u0438\u0439\u043C", "IBAN"], ["accountName", "string", "\u0422\u0438\u0439\u043C", "\u0414\u0430\u043D\u0441\u043D\u044B \u043D\u044D\u0440"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"]], null));

children.push(...detailBlock("1.9 \u041D\u0443\u0443\u0446 \u04AF\u0433 \u0441\u044D\u0440\u0433\u044D\u044D\u0445 \u044D\u0445\u043B\u04AF\u04AF\u043B\u044D\u0445", "POST", "/bdc/api/auth/forgot_password/initiate",
  [["registerNumber", "string", "\u0422\u0438\u0439\u043C", "\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440"], ["phone", "string", "\u0422\u0438\u0439\u043C", "\u0423\u0442\u0430\u0441"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"], ["data.sessionId", "string", "\u0422\u0438\u0439\u043C", "Session ID"], ["data.channels", "array", "\u0422\u0438\u0439\u043C", "\u0421\u0443\u0432\u0430\u0433\u0443\u0443\u0434 (sms/email)"]], null));

children.push(...detailBlock("1.10 \u0428\u0438\u043D\u044D \u043D\u0443\u0443\u0446 \u04AF\u0433 \u0442\u043E\u0433\u0442\u043E\u043E\u0445", "POST", "/bdc/api/auth/forgot_password/reset",
  [["sessionId", "string", "\u0422\u0438\u0439\u043C", "Session ID"], ["password", "string", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043D\u044D \u043D\u0443\u0443\u0446 \u04AF\u0433"], ["confirmPassword", "string", "\u0422\u0438\u0439\u043C", "\u0414\u0430\u0432\u0442\u0430\u0445"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// ========== 2. OTP ==========
children.push(sectionHeading("2. OTP \u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442 / Verification"));
children.push(bodyText("Login, \u0431\u04AF\u0440\u0442\u0433\u044D\u043B, \u043D\u0443\u0443\u0446 \u04AF\u0433 \u0441\u043E\u043B\u0438\u0445 \u04AF\u0435\u0434 \u0445\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0434\u044D\u0445 OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442. Login \u04AF\u0435\u0434 deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043B\u0433\u04AF\u0439 \u0431\u043E\u043B OTP \u0448\u0430\u0430\u0440\u0434\u043D\u0430."));

children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/auth/verification_channels", "\u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445 \u0441\u0443\u0432\u0430\u0433 \u0430\u0432\u0430\u0445", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("2", "POST", "/bdc/api/auth/send_otp", "OTP \u0438\u043B\u0433\u044D\u044D\u0445", "\u04AE\u0433\u04AF\u0439", undefined),
  apiRow("3", "POST", "/bdc/api/auth/verify_otp", "OTP \u0448\u0430\u043B\u0433\u0430\u0445", "\u04AE\u0433\u04AF\u0439", "F8FAFA"),
  apiRow("4", "POST", "/bdc/api/auth/resend_otp", "OTP \u0434\u0430\u0445\u0438\u043D \u0438\u043B\u0433\u044D\u044D\u0445", "\u04AE\u0433\u04AF\u0439", undefined),
]));

children.push(...detailBlock("2.1 \u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445 \u0441\u0443\u0432\u0430\u0433", "GET", "/bdc/api/auth/verification_channels?sessionId={sessionId}", null,
  [["data.channels", "array", "\u0422\u0438\u0439\u043C", "[{type: \"sms\", value: \"80****72\"}, {type: \"email\", value: \"m****@gmail.mn\"}]"]], null));

children.push(...detailBlock("2.2 OTP \u0438\u043B\u0433\u044D\u044D\u0445", "POST", "/bdc/api/auth/send_otp",
  [["sessionId", "string", "\u0422\u0438\u0439\u043C", "Session ID"], ["channel", "string", "\u0422\u0438\u0439\u043C", "\"sms\" | \"email\""]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"], ["data.expiresIn", "int", "\u0422\u0438\u0439\u043C", "OTP \u0445\u04AF\u0447\u0438\u043D\u0442\u044D\u0439 \u0445\u0443\u0433\u0430\u0446\u0430\u0430 (\u0441\u0435\u043A\u0443\u043D\u0434)"]], null));

children.push(...detailBlock("2.3 OTP \u0448\u0430\u043B\u0433\u0430\u0445", "POST", "/bdc/api/auth/verify_otp",
  [["sessionId", "string", "\u0422\u0438\u0439\u043C", "Session ID"], ["otpCode", "string", "\u0422\u0438\u0439\u043C", "OTP \u043A\u043E\u0434 (4-6 \u043E\u0440\u043E\u043D)"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0437\u04E9\u0432"]], "Login OTP \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0441\u043D\u044B \u0434\u0430\u0440\u0430\u0430 register_device API \u0434\u0443\u0443\u0434\u0430\u0436 deviceId \u0431\u04AF\u0440\u0442\u0433\u044D\u043D\u044D."));

children.push(new Paragraph({ children: [new PageBreak()] }));

// ========== 3. KYC ==========
children.push(sectionHeading("3. KYC / \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447 \u0442\u0430\u043D\u0438\u043B\u0442"));
children.push(bodyText("\u041D\u044D\u0432\u0442\u0440\u044D\u0441\u043D\u0438\u0439 \u0434\u0430\u0440\u0430\u0430 \u0445\u0438\u0439\u0445 KYC \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442 (PEP, \u0431\u0438\u0447\u0438\u0433 \u0431\u0430\u0440\u0438\u043C\u0442, DAN \u0448\u0430\u043B\u0433\u0430\u043B\u0442, \u0433\u044D\u0440\u044D\u044D \u0437\u04E9\u0432\u0448\u04E9\u04E9\u0440\u04E9\u0445). Auth \u0448\u0430\u0430\u0440\u0434\u043B\u0430\u0433\u0430\u0442\u0430\u0439."));

children.push(apiTable([
  apiRow("1", "POST", "/bdc/api/kyc/pep_status", "PEP \u0441\u0442\u0430\u0442\u0443\u0441", "Bearer", "F8FAFA"),
  apiRow("2", "POST", "/bdc/api/kyc/upload_document", "\u0417\u0443\u0440\u0430\u0433 upload", "Bearer", undefined),
  apiRow("3", "POST", "/bdc/api/kyc/submit_verification", "KYC \u0431\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("4", "POST", "/bdc/api/kyc/dan_verification", "DAN \u0448\u0430\u043B\u0433\u0430\u043B\u0442", "Bearer", undefined),
  apiRow("5", "POST", "/bdc/api/kyc/accept_agreement", "\u0413\u044D\u0440\u044D\u044D \u0437\u04E9\u0432\u0448\u04E9\u04E9\u0440\u04E9\u0445", "Bearer", "F8FAFA"),
  apiRow("6", "GET", "/bdc/api/banks/list", "\u0411\u0430\u043D\u043A\u0443\u0443\u0434\u044B\u043D \u0436\u0430\u0433\u0441\u0430\u0430\u043B\u0442", "\u04AE\u0433\u04AF\u0439", undefined),
]));

children.push(...detailBlock("3.1 PEP \u0441\u0442\u0430\u0442\u0443\u0441", "POST", "/bdc/api/kyc/pep_status",
  [["isPep", "boolean", "\u0422\u0438\u0439\u043C", "true = \u0423\u043B\u0441 \u0442\u04E9\u0440\u0438\u0439\u043D \u043D\u04E9\u043B\u04E9\u04E9\u0442\u044D\u0439 \u0445\u04AF\u043D"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"]], null));

children.push(...detailBlock("3.2 \u0411\u0438\u0447\u0438\u0433 \u0431\u0430\u0440\u0438\u043C\u0442 upload", "POST", "/bdc/api/kyc/upload_document",
  [["type", "string", "\u0422\u0438\u0439\u043C", "\"id_front\" | \"id_back\" | \"selfie\""], ["image", "file", "\u0422\u0438\u0439\u043C", "Multipart form-data"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0430\u043C\u0436\u0438\u043B\u0442\u0442\u0430\u0439"], ["data.documentId", "string", "\u0422\u0438\u0439\u043C", "Upload ID"]], "Content-Type: multipart/form-data"));

children.push(...detailBlock("3.3 DAN \u0448\u0430\u043B\u0433\u0430\u043B\u0442", "POST", "/bdc/api/kyc/dan_verification",
  [["registerNumber", "string", "\u0422\u0438\u0439\u043C", "\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0439\u043D \u0434\u0443\u0433\u0430\u0430\u0440"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = \u0446\u044D\u0432\u044D\u0440"], ["data.status", "string", "\u0422\u0438\u0439\u043C", "\"clear\" | \"flagged\""]], null));

children.push(...detailBlock("3.4 \u0411\u0430\u043D\u043A\u0443\u0443\u0434\u044B\u043D \u0436\u0430\u0433\u0441\u0430\u0430\u043B\u0442", "GET", "/bdc/api/banks/list", null,
  [["data", "array", "\u0422\u0438\u0439\u043C", "[{code: \"KHAN\", name: \"\u0425\u0430\u0430\u043D \u0431\u0430\u043D\u043A\"}, ...]"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// ========== 4-11: same as before ==========
// 4. Dashboard
children.push(sectionHeading("4. \u041D\u04AF\u04AF\u0440 \u0445\u0443\u0443\u0434\u0430\u0441 / Dashboard"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/portfolio/summary", "\u041D\u0438\u0439\u0442 \u0445\u04E9\u0440\u04E9\u043D\u0433\u04E9, P&L", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/portfolio/chart_data", "Equity \u0433\u0440\u0430\u0444\u0438\u043A", "Bearer", undefined),
  apiRow("3", "GET", "/bdc/api/portfolio/breakdown", "\u0425\u04E9\u0440\u04E9\u043D\u0433\u0438\u0439\u043D \u0445\u0443\u0432\u0430\u0430\u0440\u0438\u043B\u0430\u043B\u0442", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/recommendations", "\u0417\u04E9\u0432\u043B\u04E9\u043C\u0436 \u04AF\u043D\u044D\u0442 \u0446\u0430\u0430\u0441", "Bearer", undefined),
  apiRow("5", "GET", "/bdc/api/watchlist/preview", "Watchlist \u0442\u043E\u0432\u0447", "Bearer", "F8FAFA"),
]));
children.push(...detailBlock("4.1 \u041D\u0438\u0439\u0442 \u0445\u04E9\u0440\u04E9\u043D\u0433\u04E9", "GET", "/bdc/api/portfolio/summary", null,
  [["data.totalAssets", "number", "\u0422\u0438\u0439\u043C", "\u041D\u0438\u0439\u0442 \u0445\u04E9\u0440\u04E9\u043D\u0433\u04E9 (MNT)"], ["data.totalChange", "number", "\u0422\u0438\u0439\u043C", "\u04E8\u04E9\u0440\u0447\u043B\u04E9\u043B\u0442"], ["data.changePercent", "number", "\u0422\u0438\u0439\u043C", "\u04E8\u04E9\u0440\u0447\u043B\u04E9\u043B\u0442 %"], ["data.cashBalance", "number", "\u0422\u0438\u0439\u043C", "\u0411\u044D\u043B\u044D\u043D \u043C\u04E9\u043D\u0433\u04E9"], ["data.registrationProgress", "number", "\u04AE\u0433\u04AF\u0439", "\u0411\u04AF\u0440\u0442\u0433\u044D\u043B\u0438\u0439\u043D \u044F\u0432\u0446 (0-100)"]], null));
children.push(...detailBlock("4.2 Equity \u0433\u0440\u0430\u0444\u0438\u043A", "GET", "/bdc/api/portfolio/chart_data?period={1W|1M|3M|1Y|ALL}", null,
  [["data.points", "array", "\u0422\u0438\u0439\u043C", "[{date, value}]"], ["data.period", "string", "\u0422\u0438\u0439\u043C", "\u0421\u043E\u043D\u0433\u043E\u0441\u043E\u043D \u0445\u0443\u0433\u0430\u0446\u0430\u0430"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 5. Bonds
children.push(sectionHeading("5. \u0411\u043E\u043D\u0434 / Bonds"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/bonds/primary_market", "\u0410\u043D\u0445\u0434\u0430\u0433\u0447 \u0437\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/bonds/secondary_market", "\u0425\u043E\u04B1\u0434\u0430\u0433\u0447 \u0437\u0430\u0445", "Bearer", undefined),
  apiRow("3", "GET", "/bdc/api/bonds/my_bonds", "\u041C\u0438\u043D\u0438\u0439 \u0431\u043E\u043D\u0434\u0443\u0443\u0434", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/bonds/{bondId}", "\u0414\u044D\u043B\u0433\u044D\u0440\u044D\u043D\u0433\u04AF\u0439", "Bearer", undefined),
  apiRow("5", "GET", "/bdc/api/bonds/{bondId}/trading_info", "\u0410\u0440\u0438\u043B\u0436\u0430\u0430\u043D\u044B \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "Bearer", "F8FAFA"),
  apiRow("6", "GET", "/bdc/api/account/cash_balance", "\u0411\u044D\u043B\u044D\u043D \u043C\u04E9\u043D\u0433\u04E9", "Bearer", undefined),
  apiRow("7", "POST", "/bdc/api/bonds/buy/confirm", "\u0411\u043E\u043D\u0434 \u0430\u0432\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("8", "GET", "/bdc/api/bonds/{bondId}/sell_info", "\u0417\u0430\u0440\u0430\u0445 \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "Bearer", undefined),
  apiRow("9", "POST", "/bdc/api/bonds/sell/confirm", "\u0411\u043E\u043D\u0434 \u0437\u0430\u0440\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("10", "GET", "/bdc/api/portfolio/bonds", "\u0411\u0430\u0433\u0446\u0438\u0439\u043D \u0431\u043E\u043D\u0434\u0443\u0443\u0434", "Bearer", undefined),
]));
children.push(...detailBlock("5.1 \u0411\u043E\u043D\u0434 \u0430\u0432\u0430\u0445", "POST", "/bdc/api/bonds/buy/confirm",
  [["bondId", "string", "\u0422\u0438\u0439\u043C", "\u0411\u043E\u043D\u0434\u044B\u043D ID"], ["quantity", "int", "\u0422\u0438\u0439\u043C", "\u0422\u043E\u043E"], ["totalAmount", "number", "\u0422\u0438\u0439\u043C", "\u041D\u0438\u0439\u0442 \u0434\u04AF\u043D"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"], ["data.orderId", "string", "\u0422\u0438\u0439\u043C", "\u0417\u0430\u0445\u0438\u0430\u043B\u0433\u044B\u043D ID"], ["data.orderRef", "string", "\u0422\u0438\u0439\u043C", "\u041B\u0430\u0432\u043B\u0430\u0445 \u0434\u0443\u0433\u0430\u0430\u0440"]], null));
children.push(...detailBlock("5.2 \u0411\u043E\u043D\u0434 \u0437\u0430\u0440\u0430\u0445", "POST", "/bdc/api/bonds/sell/confirm",
  [["bondId", "string", "\u0422\u0438\u0439\u043C", "\u0411\u043E\u043D\u0434\u044B\u043D ID"], ["quantity", "int", "\u0422\u0438\u0439\u043C", "\u0417\u0430\u0440\u0430\u0445 \u0442\u043E\u043E"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"], ["data.orderId", "string", "\u0422\u0438\u0439\u043C", "\u0417\u0430\u0445\u0438\u0430\u043B\u0433\u044B\u043D ID"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 6. Stocks
children.push(sectionHeading("6. \u0425\u0443\u0432\u044C\u0446\u0430\u0430 / Stocks"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/stocks/list", "\u0416\u0430\u0433\u0441\u0430\u0430\u043B\u0442", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/stocks/search?q={query}", "\u0425\u0430\u0439\u043B\u0442", "Bearer", undefined),
  apiRow("3", "GET", "/bdc/api/stocks/gainers", "\u04E8\u0441\u04E9\u043B\u0442\u0442\u044D\u0439", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/stocks/losers", "\u0411\u0443\u0443\u0440\u0430\u043B\u0442\u0442\u0430\u0439", "Bearer", undefined),
  apiRow("5", "GET", "/bdc/api/stocks/ipo", "IPO", "Bearer", "F8FAFA"),
  apiRow("6", "GET", "/bdc/api/stocks/{symbol}", "\u0414\u044D\u043B\u0433\u044D\u0440\u044D\u043D\u0433\u04AF\u0439", "Bearer", undefined),
  apiRow("7", "GET", "/bdc/api/stocks/{symbol}/chart", "\u0413\u0440\u0430\u0444\u0438\u043A", "Bearer", "F8FAFA"),
  apiRow("8", "GET", "/bdc/api/stocks/{symbol}/info", "\u0422\u0430\u043B\u0431\u0430\u0440 \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "Bearer", undefined),
  apiRow("9", "GET", "/bdc/api/stocks/{symbol}/dividends", "\u041D\u043E\u0433\u0434\u043E\u043B \u0430\u0448\u0433\u0438\u0439\u043D \u0442\u04AF\u04AF\u0445", "Bearer", "F8FAFA"),
  apiRow("10", "GET", "/bdc/api/stocks/{symbol}/trading_info", "\u0410\u0440\u0438\u043B\u0436\u0430\u0430\u043D\u044B \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "Bearer", undefined),
  apiRow("11", "POST", "/bdc/api/stocks/order/confirm", "\u0417\u0430\u0445\u0438\u0430\u043B\u0433\u0430 \u0431\u0430\u0442\u043B\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("12", "GET", "/bdc/api/portfolio/stocks", "\u041C\u0438\u043D\u0438\u0439 \u0445\u0443\u0432\u044C\u0446\u0430\u0430", "Bearer", undefined),
  apiRow("13", "GET", "/bdc/api/portfolio/stocks/history", "\u0410\u0448\u0438\u0433\u0438\u0439\u043D \u0442\u04AF\u04AF\u0445", "Bearer", "F8FAFA"),
]));
children.push(...detailBlock("6.1 \u0425\u0443\u0432\u044C\u0446\u0430\u0430 \u0437\u0430\u0445\u0438\u0430\u043B\u0430\u0445", "POST", "/bdc/api/stocks/order/confirm",
  [["symbol", "string", "\u0422\u0438\u0439\u043C", "APU, AARD..."], ["side", "string", "\u0422\u0438\u0439\u043C", "\"buy\" | \"sell\""], ["price", "number", "\u0422\u0438\u0439\u043C", "\u04AE\u043D\u044D"], ["quantity", "int", "\u0422\u0438\u0439\u043C", "\u0422\u043E\u043E"], ["orderType", "string", "\u04AE\u0433\u04AF\u0439", "\"limit\" | \"market\""]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"], ["data.orderId", "string", "\u0422\u0438\u0439\u043C", "ID"], ["data.orderRef", "string", "\u0422\u0438\u0439\u043C", "\u041B\u0430\u0432\u043B\u0430\u0445 \u0434\u0443\u0433\u0430\u0430\u0440"], ["data.fee", "number", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043C\u0442\u0433\u044D\u043B"], ["data.totalAmount", "number", "\u0422\u0438\u0439\u043C", "\u041D\u0438\u0439\u0442 \u0434\u04AF\u043D"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 7. Orders & Transactions
children.push(sectionHeading("7. \u0417\u0430\u0445\u0438\u0430\u043B\u0433\u0430 \u0431\u0430 \u0413\u04AF\u0439\u043B\u0433\u044D\u044D / Orders & Transactions"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/orders/active", "\u0418\u0434\u044D\u0432\u0445\u0438\u0442\u044D\u0439 \u0437\u0430\u0445\u0438\u0430\u043B\u0433\u0443\u0443\u0434", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/orders/history", "\u0417\u0430\u0445\u0438\u0430\u043B\u0433\u044B\u043D \u0442\u04AF\u04AF\u0445", "Bearer", undefined),
  apiRow("3", "GET", "/bdc/api/orders/{orderId}", "\u0414\u044D\u043B\u0433\u044D\u0440\u044D\u043D\u0433\u04AF\u0439", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/transactions", "\u0413\u04AF\u0439\u043B\u0433\u044D\u044D\u043D\u0438\u0439 \u0442\u04AF\u04AF\u0445", "Bearer", undefined),
  apiRow("5", "GET", "/bdc/api/transactions/periods", "\u0425\u0443\u0433\u0430\u0446\u0430\u0430\u043D\u044B \u0441\u043E\u043D\u0433\u043E\u043B\u0442", "Bearer", "F8FAFA"),
  apiRow("6", "GET", "/bdc/api/portfolio/summary_report", "\u041D\u044D\u0433\u0434\u0441\u044D\u043D \u0442\u0430\u0439\u043B\u0430\u043D", "Bearer", undefined),
]));
children.push(...detailBlock("7.1 \u0413\u04AF\u0439\u043B\u0433\u044D\u044D\u043D\u0438\u0439 \u0442\u04AF\u04AF\u0445", "GET", "/bdc/api/transactions?type={all|cash|bond|stock}&period={3m|6m|1y}&page={1}", null,
  [["data.items", "array", "\u0422\u0438\u0439\u043C", "[{id, type, description, amount, currency, date, status}]"], ["data.totalCount", "int", "\u0422\u0438\u0439\u043C", "\u041D\u0438\u0439\u0442 \u0442\u043E\u043E"], ["data.page", "int", "\u0422\u0438\u0439\u043C", "\u0425\u0443\u0443\u0434\u0430\u0441"]], null));
children.push(...detailBlock("7.2 \u0417\u0430\u0445\u0438\u0430\u043B\u0433\u044B\u043D \u0434\u044D\u043B\u0433\u044D\u0440\u044D\u043D\u0433\u04AF\u0439", "GET", "/bdc/api/orders/{orderId}", null,
  [["data.orderId", "string", "\u0422\u0438\u0439\u043C", "ID"], ["data.symbol", "string", "\u0422\u0438\u0439\u043C", "\u041D\u044D\u0440"], ["data.side", "string", "\u0422\u0438\u0439\u043C", "buy|sell"], ["data.price", "number", "\u0422\u0438\u0439\u043C", "\u04AE\u043D\u044D"], ["data.quantity", "int", "\u0422\u0438\u0439\u043C", "\u0422\u043E\u043E"], ["data.fee", "number", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043C\u0442\u0433\u044D\u043B"], ["data.status", "string", "\u0422\u0438\u0439\u043C", "pending|filled|cancelled"], ["data.timeline", "array", "\u0422\u0438\u0439\u043C", "[{date, event}]"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 8. Cash Management
children.push(sectionHeading("8. \u041C\u04E9\u043D\u0433\u04E9\u043D \u0443\u0434\u0438\u0440\u0434\u043B\u0430\u0433\u0430 / Cash Management"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/account/currency/{code}", "\u0412\u0430\u043B\u044E\u0442\u044B\u043D \u04AF\u043B\u0434\u044D\u0433\u0434\u044D\u043B", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/account/cash_balance", "\u0411\u044D\u043B\u044D\u043D \u043C\u04E9\u043D\u0433\u04E9", "Bearer", undefined),
  apiRow("3", "POST", "/bdc/api/accounts/add", "\u0414\u0430\u043D\u0441 \u043D\u044D\u043C\u044D\u0445", "Bearer", "F8FAFA"),
  apiRow("4", "POST", "/bdc/api/accounts/validate_iban", "IBAN \u0448\u0430\u043B\u0433\u0430\u0445", "Bearer", undefined),
  apiRow("5", "POST", "/bdc/api/accounts/{id}/set_default", "\u04AE\u043D\u0434\u0441\u044D\u043D \u0434\u0430\u043D\u0441", "Bearer", "F8FAFA"),
  apiRow("6", "POST", "/bdc/api/account/deposit", "\u041E\u0440\u043B\u043E\u0433\u043E \u043E\u0440\u0443\u0443\u043B\u0430\u0445", "Bearer", undefined),
  apiRow("7", "POST", "/bdc/api/account/withdraw", "\u0417\u0430\u0440\u043B\u0430\u0433\u0430 \u0433\u0430\u0440\u0433\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("8", "GET", "/bdc/api/account/locked_amounts", "\u0422\u04AF\u0433\u0436\u044D\u044D\u0441\u044D\u043D \u043C\u04E9\u043D\u0433\u04E9", "Bearer", undefined),
  apiRow("9", "POST", "/bdc/api/account/release_locked", "\u0422\u04AF\u0433\u0436\u044D\u044D \u0442\u0430\u0439\u043B\u0430\u0445", "Bearer", "F8FAFA"),
]));
children.push(...detailBlock("8.1 \u041E\u0440\u043B\u043E\u0433\u043E \u043E\u0440\u0443\u0443\u043B\u0430\u0445", "POST", "/bdc/api/account/deposit",
  [["amount", "number", "\u0422\u0438\u0439\u043C", "\u0414\u04AF\u043D"], ["currency", "string", "\u0422\u0438\u0439\u043C", "\"MNT\"|\"USD\""], ["method", "string", "\u0422\u0438\u0439\u043C", "\"qpay\"|\"bank_transfer\""]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"], ["data.transactionId", "string", "\u0422\u0438\u0439\u043C", "ID"], ["data.qpayUrl", "string", "\u04AE\u0433\u04AF\u0439", "QPay \u043B\u0438\u043D\u043A"]], null));
children.push(...detailBlock("8.2 \u0417\u0430\u0440\u043B\u0430\u0433\u0430 \u0433\u0430\u0440\u0433\u0430\u0445", "POST", "/bdc/api/account/withdraw",
  [["amount", "number", "\u0422\u0438\u0439\u043C", "\u0414\u04AF\u043D"], ["currency", "string", "\u0422\u0438\u0439\u043C", "\"MNT\"|\"USD\""], ["accountId", "string", "\u0422\u0438\u0439\u043C", "\u0414\u0430\u043D\u0441\u043D\u044B ID"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"], ["data.transactionId", "string", "\u0422\u0438\u0439\u043C", "ID"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 9. Watchlist
children.push(sectionHeading("9. Watchlist"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/watchlist", "\u0416\u0430\u0433\u0441\u0430\u0430\u043B\u0442", "Bearer", "F8FAFA"),
  apiRow("2", "POST", "/bdc/api/watchlist/{symbol}", "\u041D\u044D\u043C\u044D\u0445", "Bearer", undefined),
  apiRow("3", "DELETE", "/bdc/api/watchlist/{symbol}", "\u0425\u0430\u0441\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/stocks/available", "\u0411\u043E\u043B\u043E\u043C\u0436\u0442\u043E\u0439 \u0445\u0443\u0432\u044C\u0446\u0430\u0430", "Bearer", undefined),
]));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 10. User & Notifications
children.push(sectionHeading("10. \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447 \u0431\u0430 \u041C\u044D\u0434\u044D\u0433\u0434\u044D\u043B / User & Notifications"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/user/info", "\u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "Bearer", "F8FAFA"),
  apiRow("2", "PUT", "/bdc/api/user/info", "\u041C\u044D\u0434\u044D\u044D\u043B\u044D\u043B \u0437\u0430\u0441\u0430\u0445", "Bearer", undefined),
  apiRow("3", "POST", "/bdc/api/auth/change_password", "\u041D\u0443\u0443\u0446 \u04AF\u0433 \u0441\u043E\u043B\u0438\u0445", "Bearer", "F8FAFA"),
  apiRow("4", "GET", "/bdc/api/security/devices", "\u0422\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436\u04AF\u04AF\u0434", "Bearer", undefined),
  apiRow("5", "DELETE", "/bdc/api/security/devices/{deviceId}", "\u0422\u04E9\u0445\u04E9\u04E9\u0440\u04E9\u043C\u0436 \u0445\u0430\u0441\u0430\u0445", "Bearer", "F8FAFA"),
  apiRow("6", "GET", "/bdc/api/notifications?filter={all}", "\u041C\u044D\u0434\u044D\u0433\u0434\u043B\u04AF\u04AF\u0434", "Bearer", undefined),
  apiRow("7", "POST", "/bdc/api/notifications/mark_all_read", "\u0411\u04AF\u0433\u0434\u0438\u0439\u0433 \u0443\u043D\u0448\u0441\u0430\u043D\u0434 \u0442\u044D\u043C\u0434\u044D\u0433\u043B\u044D\u0445", "Bearer", "F8FAFA"),
]));
children.push(...detailBlock("10.1 \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447\u0438\u0439\u043D \u043C\u044D\u0434\u044D\u044D\u043B\u044D\u043B", "GET", "/bdc/api/user/info", null,
  [["data.uid", "string", "\u0422\u0438\u0439\u043C", "ID"], ["data.lastName", "string", "\u0422\u0438\u0439\u043C", "\u041E\u0432\u043E\u0433"], ["data.firstName", "string", "\u0422\u0438\u0439\u043C", "\u041D\u044D\u0440"], ["data.registerNumber", "string", "\u0422\u0438\u0439\u043C", "\u0420\u0414"], ["data.email", "string", "\u04AE\u0433\u04AF\u0439", "\u0418\u043C\u044D\u0439\u043B"], ["data.emailVerified", "boolean", "\u04AE\u0433\u04AF\u0439", "\u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0441\u0430\u043D \u044D\u0441\u044D\u0445"], ["data.phone", "string", "\u0422\u0438\u0439\u043C", "\u0423\u0442\u0430\u0441"], ["data.address", "string", "\u04AE\u0433\u04AF\u0439", "\u0425\u0430\u044F\u0433"]], null));
children.push(...detailBlock("10.2 \u041D\u0443\u0443\u0446 \u04AF\u0433 \u0441\u043E\u043B\u0438\u0445", "POST", "/bdc/api/auth/change_password",
  [["currentPassword", "string", "\u0422\u0438\u0439\u043C", "\u041E\u0434\u043E\u043E\u0433\u0438\u0439\u043D"], ["newPassword", "string", "\u0422\u0438\u0439\u043C", "\u0428\u0438\u043D\u044D"], ["confirmPassword", "string", "\u0422\u0438\u0439\u043C", "\u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u0445"]],
  [["code", "string", "\u0422\u0438\u0439\u043C", "\"0\" = OK"]], null));

children.push(new Paragraph({ children: [new PageBreak()] }));

// 11. Savings
children.push(sectionHeading("11. \u0425\u0430\u0434\u0433\u0430\u043B\u0430\u043C\u0436 / Savings"));
children.push(apiTable([
  apiRow("1", "GET", "/bdc/api/savings/my_savings", "\u041C\u0438\u043D\u0438\u0439 \u0445\u0430\u0434\u0433\u0430\u043B\u0430\u043C\u0436", "Bearer", "F8FAFA"),
  apiRow("2", "GET", "/bdc/api/savings/finished", "\u0414\u0443\u0443\u0441\u0441\u0430\u043D", "Bearer", undefined),
]));

children.push(new Paragraph({ spacing: { before: 300 }, children: [] }));

// ========== SUMMARY ==========
children.push(new Paragraph({ border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "1B5E6B", space: 1 } }, spacing: { after: 200 }, children: [] }));
children.push(new Paragraph({ spacing: { after: 200 }, children: [new TextRun({ text: "\u041D\u0438\u0439\u0442 \u0442\u043E\u043E\u0446\u043E\u043E / Summary", font: "Arial", size: 28, bold: true, color: "1B5E6B" })] }));

const summaryData = [
  ["\u041D\u044D\u0432\u0442\u0440\u044D\u043B\u0442 / Authentication", "10"],
  ["OTP \u0411\u0430\u0442\u0430\u043B\u0433\u0430\u0430\u0436\u0443\u0443\u043B\u0430\u043B\u0442", "4"],
  ["KYC / \u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447 \u0442\u0430\u043D\u0438\u043B\u0442", "6"],
  ["\u041D\u04AF\u04AF\u0440 \u0445\u0443\u0443\u0434\u0430\u0441 / Dashboard", "5"],
  ["\u0411\u043E\u043D\u0434 / Bonds", "10"],
  ["\u0425\u0443\u0432\u044C\u0446\u0430\u0430 / Stocks", "13"],
  ["\u0417\u0430\u0445\u0438\u0430\u043B\u0433\u0430 \u0431\u0430 \u0413\u04AF\u0439\u043B\u0433\u044D\u044D", "6"],
  ["\u041C\u04E9\u043D\u0433\u04E9\u043D \u0443\u0434\u0438\u0440\u0434\u043B\u0430\u0433\u0430 / Cash", "9"],
  ["Watchlist", "4"],
  ["\u0425\u044D\u0440\u044D\u0433\u043B\u044D\u0433\u0447 \u0431\u0430 \u043C\u044D\u0434\u044D\u0433\u0434\u044D\u043B", "7"],
  ["\u0425\u0430\u0434\u0433\u0430\u043B\u0430\u043C\u0436 / Savings", "2"],
];

const sumColName = 5400;
const sumColCount = 2960;
children.push(new Table({
  width: { size: sumColName + sumColCount, type: WidthType.DXA },
  columnWidths: [sumColName, sumColCount],
  rows: [
    new TableRow({ children: [
      new TableCell({ borders: headerBorders, width: { size: sumColName, type: WidthType.DXA }, shading: { fill: "1B5E6B", type: ShadingType.CLEAR }, margins: cellMargins, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "\u0425\u044D\u0441\u044D\u0433 / Section", bold: true, color: "FFFFFF", font: "Arial", size: 20 })] })] }),
      new TableCell({ borders: headerBorders, width: { size: sumColCount, type: WidthType.DXA }, shading: { fill: "1B5E6B", type: ShadingType.CLEAR }, margins: cellMargins, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Endpoints", bold: true, color: "FFFFFF", font: "Arial", size: 20 })] })] }),
    ] }),
    ...summaryData.map((row, i) => new TableRow({ children: [
      cell(row[0], sumColName, { fill: i % 2 === 0 ? "F0F7F7" : undefined }),
      cell(row[1], sumColCount, { align: AlignmentType.CENTER, fill: i % 2 === 0 ? "F0F7F7" : undefined, bold: true }),
    ] })),
    new TableRow({ children: [
      cell("\u041D\u0438\u0439\u0442 / TOTAL", sumColName, { bold: true, fill: "E0F0EF" }),
      cell("76", sumColCount, { align: AlignmentType.CENTER, bold: true, fill: "E0F0EF", color: "1B5E6B" }),
    ] }),
  ],
}));

// ========== DOCUMENT ==========
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 20 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 30, bold: true, font: "Arial", color: "1B5E6B" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, font: "Arial", color: "1B5E6B" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 22, bold: true, font: "Arial", color: "2E7D8C" },
        paragraph: { spacing: { before: 120, after: 120 }, outlineLevel: 2 } },
    ],
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1200, right: 1200, bottom: 1200, left: 1200 },
      },
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          alignment: AlignmentType.RIGHT,
          border: { bottom: { style: BorderStyle.SINGLE, size: 2, color: "1B5E6B", space: 4 } },
          children: [new TextRun({ text: "Mandal Capital \u2014 API Requirements v1.1", font: "Arial", size: 16, color: "999999" })],
        })],
      }),
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          border: { top: { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC", space: 4 } },
          children: [
            new TextRun({ text: "Page ", font: "Arial", size: 16, color: "999999" }),
            new TextRun({ children: [PageNumber.CURRENT], font: "Arial", size: 16, color: "999999" }),
          ],
        })],
      }),
    },
    children,
  }],
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("C:\\Users\\hitech\\OneDrive\\Documents\\antigravity\\api_requirements.docx", buffer);
  console.log("api_requirements.docx v1.1 updated!");
});
