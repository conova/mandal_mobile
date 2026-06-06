const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.333 x 7.5

// Color palette — "Ocean Gradient" with strong navy dominance
const C = {
  bgDark: "0B1E33",     // deep navy
  bgLight: "F4F6F8",    // off-white
  primary: "065A82",    // deep blue
  secondary: "1C7293",  // teal
  accent: "F2A341",     // amber accent
  textDark: "0F1B2D",
  textMuted: "5A6B7B",
  textLight: "FFFFFF",
  cardBg: "FFFFFF",
  border: "D6DEE5",
  success: "2DAA73",
  danger: "D8595A",
};

const F = { head: "Cambria", body: "Calibri" };

// ----- Helpers -----
function darkBg(slide) {
  slide.background = { color: C.bgDark };
}
function lightBg(slide) {
  slide.background = { color: C.bgLight };
}
function slideNumber(slide, n, total) {
  slide.addText(`${n} / ${total}`, {
    x: 12.5, y: 7.05, w: 0.7, h: 0.3,
    fontFace: F.body, fontSize: 10, color: C.textMuted, align: "right",
  });
}
function topTitle(slide, eyebrow, title) {
  slide.addText(eyebrow, {
    x: 0.6, y: 0.45, w: 12, h: 0.35,
    fontFace: F.body, fontSize: 12, bold: true,
    color: C.accent, charSpacing: 4,
  });
  slide.addText(title, {
    x: 0.6, y: 0.78, w: 12, h: 0.9,
    fontFace: F.head, fontSize: 32, bold: true,
    color: C.textDark,
  });
}

const TOTAL = 14;

// =====================================================================
// Slide 1 — Title
// =====================================================================
{
  const s = pres.addSlide();
  darkBg(s);

  // Decorative side block
  s.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 4.4, h: 7.5,
    fill: { color: C.primary }, line: { type: "none" },
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0, y: 5.6, w: 4.4, h: 1.9,
    fill: { color: C.secondary }, line: { type: "none" },
  });

  // Big monogram
  s.addText("UB", {
    x: 0.6, y: 1.1, w: 3.6, h: 2.4,
    fontFace: F.head, fontSize: 140, bold: true,
    color: C.textLight,
  });
  s.addText("SHOP", {
    x: 0.6, y: 3.3, w: 3.6, h: 0.8,
    fontFace: F.head, fontSize: 36, bold: true,
    color: C.accent, charSpacing: 8,
  });
  s.addText("Java • Microservices • Docker", {
    x: 0.6, y: 4.0, w: 3.6, h: 0.4,
    fontFace: F.body, fontSize: 13, color: C.textLight, charSpacing: 2,
  });

  // Right content
  s.addText("UB ДЭЛГҮҮРИЙН СИСТЕМ", {
    x: 5.0, y: 1.3, w: 7.8, h: 0.5,
    fontFace: F.body, fontSize: 14, bold: true,
    color: C.accent, charSpacing: 6,
  });
  s.addText("Sprint 13–15 ба Project III\nМикросервис архитектурын танилцуулга", {
    x: 5.0, y: 1.85, w: 7.8, h: 2.0,
    fontFace: F.head, fontSize: 40, bold: true,
    color: C.textLight, lineSpacing: 48,
  });

  // Info chips
  const chips = [
    { t: "Java 17", x: 5.0 },
    { t: "Tomcat 10.1", x: 6.4 },
    { t: "Spring Boot", x: 7.9 },
    { t: "PostgreSQL 15", x: 9.5 },
    { t: "Docker", x: 11.25 },
  ];
  chips.forEach(c => {
    s.addShape(pres.ShapeType.roundRect, {
      x: c.x, y: 4.2, w: 1.35, h: 0.4,
      fill: { color: "FFFFFF", transparency: 88 },
      line: { color: C.accent, width: 1 },
      rectRadius: 0.2,
    });
    s.addText(c.t, {
      x: c.x, y: 4.2, w: 1.35, h: 0.4,
      fontFace: F.body, fontSize: 10, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
  });

  // Footer
  s.addText("Илтгэгч: Дигий  •  2026", {
    x: 5.0, y: 6.8, w: 7.8, h: 0.4,
    fontFace: F.body, fontSize: 12, color: C.textLight, charSpacing: 3,
  });
}

// =====================================================================
// Slide 2 — Agenda
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "ТАНИЛЦУУЛГЫН АГУУЛГА", "Илтгэлийн бүтэц");

  const items = [
    { n: "01", t: "Төслийн ерөнхий тойм",       d: "UB Дэлгүүр + Project III" },
    { n: "02", t: "Технологийн стек",            d: "Java, Tomcat, Spring Boot, PostgreSQL" },
    { n: "03", t: "Sprint 13 — Монолит",         d: "Swing + Servlet + Docker WAR" },
    { n: "04", t: "Sprint 14 — Microservices",   d: "frontend / book-service / db" },
    { n: "05", t: "Sprint 15 — CI/CD",           d: "GitLab pipeline (compile→dockerize)" },
    { n: "06", t: "Project III — Thesis",        d: "3 микросервис + DB-per-service" },
    { n: "07", t: "Гол үр дүн ба дүгнэлт",       d: "Сургамж, дараагийн алхам" },
  ];

  items.forEach((it, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = 0.6 + col * 6.3;
    const y = 1.85 + row * 1.15;

    // Number badge
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 0.95, h: 0.95,
      fill: { color: C.primary }, line: { type: "none" },
      rectRadius: 0.12,
    });
    s.addText(it.n, {
      x, y, w: 0.95, h: 0.95,
      fontFace: F.head, fontSize: 24, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });

    // Text
    s.addText(it.t, {
      x: x + 1.15, y: y + 0.05, w: 5.0, h: 0.45,
      fontFace: F.head, fontSize: 17, bold: true, color: C.textDark,
    });
    s.addText(it.d, {
      x: x + 1.15, y: y + 0.5, w: 5.0, h: 0.45,
      fontFace: F.body, fontSize: 12, color: C.textMuted,
    });
  });

  slideNumber(s, 2, TOTAL);
}

// =====================================================================
// Slide 3 — Project overview
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "ТӨСЛИЙН ТОЙМ", "Юу хийсэн бэ?");

  // Left: description card
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.6, y: 1.85, w: 6.0, h: 4.8,
    fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
    rectRadius: 0.08,
  });
  s.addText("Хоёр зэрэгцэх системийг нэг repo дотор бүтээсэн", {
    x: 0.9, y: 2.05, w: 5.4, h: 0.7,
    fontFace: F.head, fontSize: 18, bold: true, color: C.primary,
  });

  const bullets = [
    { b: "Sprint 13–15:", t: "UB Дэлгүүрийн систем — монолитоос микросервис рүү шилжсэн ном/бараа худалдааны платформ." },
    { b: "Project III:",  t: "Их сургуулийн дипломын ажил бүртгэх систем — student / thesis / notification гэсэн 3 микросервис." },
    { b: "Үндсэн зорилго:", t: "Монолит → Container → Compose → CI/CD → Microservices гэсэн ахисан түвшний DevOps урсгал." },
  ];
  bullets.forEach((b, i) => {
    const y = 2.95 + i * 1.15;
    s.addShape(pres.ShapeType.ellipse, {
      x: 0.9, y: y + 0.05, w: 0.18, h: 0.18,
      fill: { color: C.accent }, line: { type: "none" },
    });
    s.addText([
      { text: b.b + " ", options: { bold: true, color: C.textDark } },
      { text: b.t, options: { color: C.textMuted } },
    ], {
      x: 1.2, y, w: 5.2, h: 1.0,
      fontFace: F.body, fontSize: 13, valign: "top",
    });
  });

  // Right: stat callouts
  const stats = [
    { v: "4",  l: "Микросервис",     c: C.primary },
    { v: "4",  l: "PostgreSQL DB",   c: C.secondary },
    { v: "4",  l: "CI/CD stage",     c: C.accent },
    { v: "17", l: "Java хувилбар",   c: C.success },
  ];
  stats.forEach((st, i) => {
    const col = i % 2, row = Math.floor(i / 2);
    const x = 6.9 + col * 3.05;
    const y = 1.85 + row * 2.45;
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 2.85, h: 2.25,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.08,
    });
    s.addShape(pres.ShapeType.rect, {
      x, y, w: 0.12, h: 2.25,
      fill: { color: st.c }, line: { type: "none" },
    });
    s.addText(st.v, {
      x: x + 0.25, y: y + 0.25, w: 2.5, h: 1.25,
      fontFace: F.head, fontSize: 72, bold: true,
      color: st.c, align: "left",
    });
    s.addText(st.l, {
      x: x + 0.25, y: y + 1.5, w: 2.5, h: 0.6,
      fontFace: F.body, fontSize: 13, bold: true,
      color: C.textMuted, charSpacing: 2,
    });
  });

  slideNumber(s, 3, TOTAL);
}

// =====================================================================
// Slide 4 — Tech stack
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "ТЕХНОЛОГИЙН СТЕК", "Хэрэглэсэн хэрэгслүүд");

  const groups = [
    {
      title: "Backend",
      color: C.primary,
      items: ["Java 17 (Temurin)", "Jakarta Servlet 6.0", "Spring Boot 3 (microservices)", "Maven 3.9"],
    },
    {
      title: "Database",
      color: C.secondary,
      items: ["PostgreSQL 15-alpine", "H2 (embedded fallback)", "MySQL connector", "JDBC + init.sql"],
    },
    {
      title: "Frontend & UI",
      color: C.accent,
      items: ["Java Swing (desktop)", "JSP + Servlet (web)", "frontend-service контейнер", "REST JSON API"],
    },
    {
      title: "DevOps",
      color: C.success,
      items: ["Docker + Compose", "Tomcat 10.1-jdk17", "GitLab CI/CD", "Multi-stage build"],
    },
  ];

  groups.forEach((g, i) => {
    const col = i % 2, row = Math.floor(i / 2);
    const x = 0.6 + col * 6.25;
    const y = 1.85 + row * 2.55;
    const w = 6.0, h = 2.35;

    s.addShape(pres.ShapeType.roundRect, {
      x, y, w, h,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.08,
    });

    // Color circle
    s.addShape(pres.ShapeType.ellipse, {
      x: x + 0.25, y: y + 0.3, w: 0.7, h: 0.7,
      fill: { color: g.color }, line: { type: "none" },
    });
    s.addText(g.title.charAt(0), {
      x: x + 0.25, y: y + 0.3, w: 0.7, h: 0.7,
      fontFace: F.head, fontSize: 22, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
    s.addText(g.title, {
      x: x + 1.1, y: y + 0.35, w: 4.5, h: 0.6,
      fontFace: F.head, fontSize: 20, bold: true, color: C.textDark,
    });

    // Items
    s.addText(g.items.map(it => ({
      text: it, options: { bullet: { code: "25A0" }, color: C.textMuted },
    })), {
      x: x + 1.1, y: y + 1.0, w: 4.7, h: 1.25,
      fontFace: F.body, fontSize: 13, paraSpaceAfter: 4,
    });
  });

  slideNumber(s, 4, TOTAL);
}

// =====================================================================
// Slide 5 — Sprint 13 (Dockerized Monolith)
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "SPRINT 13", "Dockerized монолит апп");

  // Left: description
  s.addText("Бэлэн Swing desktop апп + Java Servlet вебийг нэг WAR файл болгож Tomcat дээр Dockerized хэлбэрээр deploy хийсэн.", {
    x: 0.6, y: 1.85, w: 6.2, h: 1.2,
    fontFace: F.body, fontSize: 14, color: C.textDark, lineSpacing: 22,
  });

  const features = [
    { ic: "M", t: "Monolith WAR", d: "shop-app.war → Tomcat ROOT" },
    { ic: "D", t: "Docker image", d: "tomcat:10.1-jdk17 base" },
    { ic: "H", t: "H2 fallback",  d: "DB_URL env → MySQL/PG/H2" },
    { ic: "V", t: "Volume",       d: "/app/db persisted" },
  ];
  features.forEach((f, i) => {
    const y = 3.15 + i * 0.78;
    s.addShape(pres.ShapeType.ellipse, {
      x: 0.6, y, w: 0.55, h: 0.55,
      fill: { color: C.primary }, line: { type: "none" },
    });
    s.addText(f.ic, {
      x: 0.6, y, w: 0.55, h: 0.55,
      fontFace: F.head, fontSize: 18, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
    s.addText(f.t, {
      x: 1.3, y: y - 0.02, w: 5.4, h: 0.32,
      fontFace: F.head, fontSize: 15, bold: true, color: C.textDark,
    });
    s.addText(f.d, {
      x: 1.3, y: y + 0.28, w: 5.4, h: 0.32,
      fontFace: F.body, fontSize: 12, color: C.textMuted,
    });
  });

  // Right: code box
  s.addShape(pres.ShapeType.roundRect, {
    x: 7.0, y: 1.85, w: 5.7, h: 5.0,
    fill: { color: C.bgDark }, line: { type: "none" },
    rectRadius: 0.08,
  });
  s.addText("Dockerfile", {
    x: 7.25, y: 1.95, w: 5.2, h: 0.4,
    fontFace: F.body, fontSize: 11, bold: true,
    color: C.accent, charSpacing: 3,
  });
  s.addText(
`FROM tomcat:10.1-jdk17

RUN rm -rf /usr/local/tomcat/webapps/* \\
 && mkdir -p /app/db

ENV DB_URL="jdbc:h2:file:/app/db/shopdb"
ENV DB_USER="sa"
ENV DB_PASSWORD=""

COPY target/*.war \\
     /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]`,
    {
      x: 7.25, y: 2.4, w: 5.25, h: 4.3,
      fontFace: "Consolas", fontSize: 12,
      color: "E6F0F7", lineSpacing: 18,
    });

  slideNumber(s, 5, TOTAL);
}

// =====================================================================
// Slide 6 — Sprint 14 (Compose split)
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "SPRINT 14", "Docker Compose-р үйлчилгээ салгах");

  // Three service cards in a row at top
  const services = [
    {
      t: "frontend-service",
      sub: "Public UI",
      port: "8080 (host)",
      desc: "Хэрэглэгчийн нүүр хуудас, JSON API руу прокси.",
      color: C.primary,
    },
    {
      t: "book-service",
      sub: "Internal JSON API",
      port: "/api/products /api/books",
      desc: "Зөвхөн Docker сүлжээнд харагдана.",
      color: C.secondary,
    },
    {
      t: "db (postgres)",
      sub: "PostgreSQL 15",
      port: "shop_db • init.sql",
      desc: "Persistent volume + healthcheck.",
      color: C.accent,
    },
  ];
  services.forEach((sv, i) => {
    const x = 0.6 + i * 4.2;
    const y = 1.9;
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 3.95, h: 2.45,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.1,
    });
    s.addShape(pres.ShapeType.rect, {
      x, y, w: 3.95, h: 0.35,
      fill: { color: sv.color }, line: { type: "none" },
    });
    s.addText(sv.t, {
      x: x + 0.25, y: y + 0.45, w: 3.5, h: 0.4,
      fontFace: F.head, fontSize: 17, bold: true, color: C.textDark,
    });
    s.addText(sv.sub, {
      x: x + 0.25, y: y + 0.85, w: 3.5, h: 0.32,
      fontFace: F.body, fontSize: 11, italic: true, color: sv.color,
    });
    s.addText(sv.port, {
      x: x + 0.25, y: y + 1.2, w: 3.5, h: 0.32,
      fontFace: "Consolas", fontSize: 11, color: C.textMuted,
    });
    s.addText(sv.desc, {
      x: x + 0.25, y: y + 1.55, w: 3.5, h: 0.8,
      fontFace: F.body, fontSize: 12, color: C.textDark,
    });
  });

  // Arrows between services
  [{x: 4.45}, {x: 8.65}].forEach(a => {
    s.addText("→", {
      x: a.x, y: 2.9, w: 0.3, h: 0.4,
      fontFace: F.head, fontSize: 24, bold: true, color: C.accent,
      align: "center", valign: "middle",
    });
  });

  // Bottom: explanation panel
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.6, y: 4.65, w: 12.15, h: 2.25,
    fill: { color: C.bgDark }, line: { type: "none" },
    rectRadius: 0.08,
  });
  s.addText("docker-compose.yml-ийн гол санаа", {
    x: 0.9, y: 4.8, w: 11.5, h: 0.4,
    fontFace: F.body, fontSize: 12, bold: true,
    color: C.accent, charSpacing: 3,
  });
  s.addText([
    { text: "•  ", options: { color: C.accent, bold: true } },
    { text: "Зөвхөн frontend ports: \"8080:8080\" — нийтэд нээлттэй.\n", options: { color: "E6F0F7" } },
    { text: "•  ", options: { color: C.accent, bold: true } },
    { text: "book-service ба db нь дотоод Docker network дээр л харилцана (port mapping байхгүй).\n", options: { color: "E6F0F7" } },
    { text: "•  ", options: { color: C.accent, bold: true } },
    { text: "depends_on + healthcheck → DB бэлэн болсны дараа л API асна.\n", options: { color: "E6F0F7" } },
    { text: "•  ", options: { color: C.accent, bold: true } },
    { text: "init.sql нь анх удаа эхлэхэд автомат seed хийнэ.", options: { color: "E6F0F7" } },
  ], {
    x: 0.9, y: 5.2, w: 11.5, h: 1.65,
    fontFace: F.body, fontSize: 13, lineSpacing: 22,
  });

  slideNumber(s, 6, TOTAL);
}

// =====================================================================
// Slide 7 — Sprint 15 (GitLab CI/CD)
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "SPRINT 15", "GitLab CI/CD pipeline");

  // Pipeline stages — horizontal flow
  const stages = [
    { n: "01", t: "compile",   d: "mvn clean compile\nбүх 4 модуль",       c: C.primary },
    { n: "02", t: "test",      d: "JUnit 5\nmvn test",                     c: C.secondary },
    { n: "03", t: "package",   d: "*.war + *.jar\n1 цаг хадгална",         c: C.accent },
    { n: "04", t: "dockerize", d: "main branch\nGitLab Registry",          c: C.success },
  ];
  stages.forEach((st, i) => {
    const x = 0.6 + i * 3.18;
    const y = 1.95;
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 2.85, h: 2.35,
      fill: { color: C.cardBg }, line: { color: st.c, width: 2 },
      rectRadius: 0.1,
    });
    s.addText(st.n, {
      x: x + 0.2, y: y + 0.2, w: 1.0, h: 0.4,
      fontFace: F.body, fontSize: 11, bold: true,
      color: st.c, charSpacing: 3,
    });
    s.addText(st.t, {
      x: x + 0.2, y: y + 0.6, w: 2.5, h: 0.65,
      fontFace: F.head, fontSize: 22, bold: true, color: C.textDark,
    });
    s.addText(st.d, {
      x: x + 0.2, y: y + 1.35, w: 2.5, h: 0.9,
      fontFace: F.body, fontSize: 12, color: C.textMuted, lineSpacing: 18,
    });

    if (i < stages.length - 1) {
      s.addText("›", {
        x: x + 2.88, y: y + 0.8, w: 0.3, h: 0.7,
        fontFace: F.head, fontSize: 36, bold: true,
        color: C.accent, align: "center", valign: "middle",
      });
    }
  });

  // Bottom feature row
  const facts = [
    { v: "4",      l: "stage",            c: C.primary },
    { v: "main",   l: "branch гүйцэлдэх", c: C.secondary },
    { v: ".m2",    l: "cache хадгалах",   c: C.accent },
    { v: "1ц",     l: "артифакт хугацаа", c: C.success },
  ];
  facts.forEach((f, i) => {
    const x = 0.6 + i * 3.18;
    const y = 4.75;
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 2.85, h: 2.0,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.08,
    });
    s.addText(f.v, {
      x: x + 0.2, y: y + 0.25, w: 2.5, h: 1.0,
      fontFace: F.head, fontSize: 44, bold: true,
      color: f.c, align: "left",
    });
    s.addText(f.l, {
      x: x + 0.2, y: y + 1.3, w: 2.5, h: 0.5,
      fontFace: F.body, fontSize: 12, bold: true,
      color: C.textMuted, charSpacing: 2,
    });
  });

  slideNumber(s, 7, TOTAL);
}

// =====================================================================
// Slide 8 — Project III architecture
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "PROJECT III", "Микросервис архитектур — Database per service");

  // Three services across the top
  const svc = [
    { t: "student-service",      port: ":8081", db: "student-db",      color: C.primary,   x: 0.7 },
    { t: "thesis-service",       port: ":8082", db: "thesis-db",       color: C.secondary, x: 5.05 },
    { t: "notification-service", port: ":8083", db: "notification-db", color: C.accent,    x: 9.4 },
  ];

  svc.forEach((sv) => {
    // Service card
    s.addShape(pres.ShapeType.roundRect, {
      x: sv.x, y: 1.95, w: 3.6, h: 1.6,
      fill: { color: sv.color }, line: { type: "none" },
      rectRadius: 0.1,
    });
    s.addText(sv.t, {
      x: sv.x + 0.2, y: 2.1, w: 3.2, h: 0.55,
      fontFace: F.head, fontSize: 18, bold: true, color: C.textLight,
    });
    s.addText(sv.port, {
      x: sv.x + 0.2, y: 2.65, w: 3.2, h: 0.4,
      fontFace: "Consolas", fontSize: 13, color: C.textLight,
    });
    s.addText("Spring Boot REST API", {
      x: sv.x + 0.2, y: 3.05, w: 3.2, h: 0.4,
      fontFace: F.body, fontSize: 11, italic: true, color: C.textLight,
    });

    // DB cylinder (simplified with shapes)
    s.addShape(pres.ShapeType.ellipse, {
      x: sv.x + 0.7, y: 4.6, w: 2.2, h: 0.4,
      fill: { color: C.bgDark }, line: { color: C.border, width: 1 },
    });
    s.addShape(pres.ShapeType.rect, {
      x: sv.x + 0.7, y: 4.8, w: 2.2, h: 1.0,
      fill: { color: C.bgDark }, line: { color: C.border, width: 1 },
    });
    s.addShape(pres.ShapeType.ellipse, {
      x: sv.x + 0.7, y: 5.6, w: 2.2, h: 0.4,
      fill: { color: C.bgDark }, line: { color: C.border, width: 1 },
    });
    s.addText(sv.db, {
      x: sv.x + 0.2, y: 5.0, w: 3.2, h: 0.45,
      fontFace: F.body, fontSize: 13, bold: true,
      color: C.textLight, align: "center",
    });
    s.addText("PostgreSQL 15", {
      x: sv.x + 0.2, y: 5.4, w: 3.2, h: 0.35,
      fontFace: F.body, fontSize: 10, italic: true,
      color: C.accent, align: "center",
    });

    // Connector from service to db
    s.addShape(pres.ShapeType.line, {
      x: sv.x + 1.8, y: 3.55, w: 0, h: 1.05,
      line: { color: C.textMuted, width: 1.5, dashType: "dash" },
    });
  });

  // Arrows showing thesis-service calling others
  s.addText("verify studentId →", {
    x: 4.0, y: 2.3, w: 1.4, h: 0.35,
    fontFace: F.body, fontSize: 10, italic: true,
    color: C.textDark, align: "center",
  });
  s.addShape(pres.ShapeType.line, {
    x: 5.0, y: 2.55, w: -0.7, h: 0,
    line: { color: C.primary, width: 2, endArrowType: "triangle" },
  });

  s.addText("← created notify", {
    x: 8.3, y: 2.3, w: 1.4, h: 0.35,
    fontFace: F.body, fontSize: 10, italic: true,
    color: C.textDark, align: "center",
  });
  s.addShape(pres.ShapeType.line, {
    x: 8.65, y: 2.55, w: 0.75, h: 0,
    line: { color: C.accent, width: 2, endArrowType: "triangle" },
  });

  // Footer note
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.7, y: 6.3, w: 12.2, h: 0.6,
    fill: { color: C.bgDark }, line: { type: "none" },
    rectRadius: 0.08,
  });
  s.addText("Гол зарчим: тус бүр өөрийн DB-тэй (database-per-service) — REST дуудлагаар л харилцана", {
    x: 0.9, y: 6.3, w: 11.8, h: 0.6,
    fontFace: F.body, fontSize: 13, bold: true,
    color: C.textLight, valign: "middle", charSpacing: 2,
  });

  slideNumber(s, 8, TOTAL);
}

// =====================================================================
// Slide 9 — Project III service responsibilities
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "PROJECT III", "Үйлчилгээ тус бүрийн үүрэг");

  const rows = [
    {
      name: "student-service",
      color: C.primary,
      api: "GET /students\nGET /students/{id}",
      desc: "Оюутны мастер дата. Бусад үйлчилгээ үүнээс studentId-г баталгаажуулна.",
    },
    {
      name: "thesis-service",
      color: C.secondary,
      api: "POST /theses\nGET /theses/{id}",
      desc: "Дипломын ажил үүсгэх, student-service-ээр шалгаад notification-service руу мэдэгдэл илгээнэ.",
    },
    {
      name: "notification-service",
      color: C.accent,
      api: "POST /notifications\nGET /notifications",
      desc: "Бүх системийн event log. Шинэ диплом нэмэгдсэн мэдэгдлийг хадгална.",
    },
  ];

  rows.forEach((r, i) => {
    const y = 1.95 + i * 1.55;
    s.addShape(pres.ShapeType.roundRect, {
      x: 0.6, y, w: 12.15, h: 1.4,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.08,
    });
    s.addShape(pres.ShapeType.rect, {
      x: 0.6, y, w: 0.18, h: 1.4,
      fill: { color: r.color }, line: { type: "none" },
    });
    // Name
    s.addText(r.name, {
      x: 0.95, y: y + 0.15, w: 3.5, h: 0.5,
      fontFace: F.head, fontSize: 18, bold: true, color: C.textDark,
    });
    s.addText("Микросервис", {
      x: 0.95, y: y + 0.7, w: 3.5, h: 0.35,
      fontFace: F.body, fontSize: 11, italic: true, color: r.color,
    });

    // API column
    s.addText("API", {
      x: 4.7, y: y + 0.15, w: 1.5, h: 0.3,
      fontFace: F.body, fontSize: 10, bold: true,
      color: C.textMuted, charSpacing: 3,
    });
    s.addText(r.api, {
      x: 4.7, y: y + 0.45, w: 3.5, h: 0.9,
      fontFace: "Consolas", fontSize: 11, color: C.textDark, lineSpacing: 16,
    });

    // Description
    s.addText("ҮҮРЭГ", {
      x: 8.3, y: y + 0.15, w: 1.5, h: 0.3,
      fontFace: F.body, fontSize: 10, bold: true,
      color: C.textMuted, charSpacing: 3,
    });
    s.addText(r.desc, {
      x: 8.3, y: y + 0.45, w: 4.35, h: 0.9,
      fontFace: F.body, fontSize: 12, color: C.textDark, lineSpacing: 18,
    });
  });

  slideNumber(s, 9, TOTAL);
}

// =====================================================================
// Slide 10 — Communication flow (sequence)
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "ХАРИЛЦАА", "Шинэ диплом үүсэх дараалал");

  // 3 vertical lanes
  const lanes = [
    { x: 1.6, t: "Client",                color: C.textMuted },
    { x: 4.4, t: "thesis-service",        color: C.secondary },
    { x: 7.6, t: "student-service",       color: C.primary },
    { x: 10.8, t: "notification-service", color: C.accent },
  ];
  lanes.forEach(l => {
    s.addShape(pres.ShapeType.roundRect, {
      x: l.x - 0.85, y: 1.95, w: 1.7, h: 0.5,
      fill: { color: l.color }, line: { type: "none" },
      rectRadius: 0.06,
    });
    s.addText(l.t, {
      x: l.x - 0.85, y: 1.95, w: 1.7, h: 0.5,
      fontFace: F.body, fontSize: 11, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
    // Lane line
    s.addShape(pres.ShapeType.line, {
      x: l.x, y: 2.5, w: 0, h: 4.0,
      line: { color: C.border, width: 1, dashType: "dash" },
    });
  });

  // Sequence arrows
  const steps = [
    { y: 2.85, fromX: 1.6,  toX: 4.4,  label: "POST /theses { title, studentId }",      color: C.secondary },
    { y: 3.55, fromX: 4.4,  toX: 7.6,  label: "GET /students/{id}  (existsById?)",       color: C.primary },
    { y: 4.25, fromX: 7.6,  toX: 4.4,  label: "200 OK / 404 (verified)",                  color: C.primary,  ret: true },
    { y: 4.95, fromX: 4.4,  toX: 10.8, label: "POST /notifications (thesisCreated)",     color: C.accent },
    { y: 5.65, fromX: 10.8, toX: 4.4,  label: "201 Created",                              color: C.accent, ret: true },
    { y: 6.35, fromX: 4.4,  toX: 1.6,  label: "201 Created (Thesis JSON)",                color: C.secondary, ret: true },
  ];
  steps.forEach((st, i) => {
    const dir = st.toX - st.fromX;
    s.addShape(pres.ShapeType.line, {
      x: st.fromX, y: st.y, w: dir, h: 0,
      line: {
        color: st.color,
        width: 2,
        dashType: st.ret ? "dash" : "solid",
        endArrowType: "triangle",
      },
    });
    s.addText(`${i + 1}. ${st.label}`, {
      x: Math.min(st.fromX, st.toX) + 0.1, y: st.y - 0.4, w: Math.abs(dir) - 0.2, h: 0.35,
      fontFace: F.body, fontSize: 11, bold: true,
      color: C.textDark, valign: "middle",
    });
  });

  slideNumber(s, 10, TOTAL);
}

// =====================================================================
// Slide 11 — Code structure (hexagonal)
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "ҮЙЛЧИЛГЭЭНИЙ БҮТЭЦ", "Hexagonal / Ports & Adapters");

  // Left: layers
  const layers = [
    { t: "adapters/in",    d: "REST Controller (HTTP орц)",            c: C.primary },
    { t: "application",    d: "Бизнес логик, validation, orchestration", c: C.secondary },
    { t: "domain",         d: "Entity, Value object, статус",          c: C.accent },
    { t: "ports",          d: "Repository, Client интерфейс",          c: C.success },
    { t: "adapters/out",   d: "JDBC repo, HTTP client (RestTemplate)", c: C.danger },
  ];
  layers.forEach((l, i) => {
    const y = 1.9 + i * 0.9;
    s.addShape(pres.ShapeType.roundRect, {
      x: 0.6, y, w: 6.5, h: 0.75,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.06,
    });
    s.addShape(pres.ShapeType.rect, {
      x: 0.6, y, w: 0.15, h: 0.75,
      fill: { color: l.c }, line: { type: "none" },
    });
    s.addText(l.t, {
      x: 0.9, y: y + 0.08, w: 2.4, h: 0.32,
      fontFace: "Consolas", fontSize: 14, bold: true, color: l.c,
    });
    s.addText(l.d, {
      x: 0.9, y: y + 0.4, w: 5.5, h: 0.32,
      fontFace: F.body, fontSize: 12, color: C.textMuted,
    });
  });

  // Right: code sample
  s.addShape(pres.ShapeType.roundRect, {
    x: 7.4, y: 1.9, w: 5.35, h: 4.95,
    fill: { color: C.bgDark }, line: { type: "none" },
    rectRadius: 0.08,
  });
  s.addText("ThesisApplicationService.java", {
    x: 7.6, y: 2.0, w: 5.0, h: 0.35,
    fontFace: F.body, fontSize: 10, bold: true,
    color: C.accent, charSpacing: 2,
  });
  s.addText(
`public Thesis create(CreateThesisRequest r) {
  if (r.title().isBlank())
    throw new IllegalArgumentException("title");

  if (!studentClient
        .existsById(r.studentId()))
    throw new IllegalArgumentException(
        "studentId does not exist");

  Thesis saved = thesisRepository.save(
    new Thesis(null, r.title(),
               ThesisStatus.PROPOSED,
               r.studentId()));

  notificationClient.thesisCreated(saved);
  return saved;
}`,
    {
      x: 7.6, y: 2.4, w: 5.05, h: 4.4,
      fontFace: "Consolas", fontSize: 11,
      color: "E6F0F7", lineSpacing: 17,
    });

  slideNumber(s, 11, TOTAL);
}

// =====================================================================
// Slide 12 — Running & testing
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "АЖИЛЛУУЛАХ", "Хэрхэн ажиллуулж туршихыг");

  // Left: command block
  s.addShape(pres.ShapeType.roundRect, {
    x: 0.6, y: 1.9, w: 6.2, h: 4.95,
    fill: { color: C.bgDark }, line: { type: "none" },
    rectRadius: 0.08,
  });
  s.addText("Terminal", {
    x: 0.85, y: 2.0, w: 5.8, h: 0.35,
    fontFace: F.body, fontSize: 10, bold: true,
    color: C.accent, charSpacing: 3,
  });
  s.addText(
`# Sprint 13 — Monolith
mvn clean package
docker build -t shop-monolith-img .
docker run -d -p 8080:8080 \\
  -v "$PWD/data:/app/db" \\
  --name shop-server shop-monolith-img

# Sprint 14 + Project III
docker compose up -d --build

# Project III — API тест
bash scripts/project-iii-curl-tests.sh

# Зогсоох
docker compose down`,
    {
      x: 0.85, y: 2.4, w: 5.9, h: 4.4,
      fontFace: "Consolas", fontSize: 12,
      color: "E6F0F7", lineSpacing: 19,
    });

  // Right: port table
  s.addText("Гадны портууд", {
    x: 7.2, y: 1.9, w: 5.5, h: 0.4,
    fontFace: F.head, fontSize: 16, bold: true, color: C.textDark,
  });

  const ports = [
    { p: "8080", n: "frontend-service",     d: "UB Дэлгүүрийн нүүр",       c: C.primary   },
    { p: "8081", n: "student-service",      d: "Оюутны API",                c: C.secondary },
    { p: "8082", n: "thesis-service",       d: "Дипломын API",              c: C.accent    },
    { p: "8083", n: "notification-service", d: "Мэдэгдлийн API",            c: C.success   },
  ];
  ports.forEach((p, i) => {
    const y = 2.45 + i * 1.05;
    s.addShape(pres.ShapeType.roundRect, {
      x: 7.2, y, w: 5.55, h: 0.9,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.06,
    });
    s.addShape(pres.ShapeType.roundRect, {
      x: 7.35, y: y + 0.13, w: 1.05, h: 0.65,
      fill: { color: p.c }, line: { type: "none" },
      rectRadius: 0.06,
    });
    s.addText(p.p, {
      x: 7.35, y: y + 0.13, w: 1.05, h: 0.65,
      fontFace: F.head, fontSize: 15, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
    s.addText(p.n, {
      x: 8.55, y: y + 0.1, w: 4.1, h: 0.4,
      fontFace: F.head, fontSize: 14, bold: true, color: C.textDark,
    });
    s.addText(p.d, {
      x: 8.55, y: y + 0.45, w: 4.1, h: 0.4,
      fontFace: F.body, fontSize: 11, color: C.textMuted,
    });
  });

  slideNumber(s, 12, TOTAL);
}

// =====================================================================
// Slide 13 — Lessons learned
// =====================================================================
{
  const s = pres.addSlide();
  lightBg(s);
  topTitle(s, "СУРГАМЖ", "Юу сурсан, юу нь хүндрэлтэй байсан бэ?");

  const learned = [
    { ic: "✓", t: "Нэг WAR-аас 3+ микросервис рүү", d: "Үе шаттайгаар (монолит → compose → CI/CD) шилжих стратеги ажилладаг.", c: C.success },
    { ic: "✓", t: "Database per service",            d: "Тус тусдаа PG instance — schema холигдохгүй, scale хийхэд хялбар.",     c: C.success },
    { ic: "✓", t: "Hexagonal architecture",          d: "Ports/adapters давхрага — JDBC-г HTTP-ээр амархан солиод тест бичих боломжтой.", c: C.success },
    { ic: "!", t: "Sync HTTP coupling",              d: "thesis → student дуудлага шууд хамааралтай. Async event-д шилжвэл бат бөх болно.", c: C.accent },
    { ic: "!", t: "Healthcheck-ын ач холбогдол",     d: "Compose дээр depends_on + healthcheck байхгүй бол DB бэлэн болохоос өмнө apps асч fail болдог.", c: C.accent },
    { ic: "!", t: "Image хэмжээ",                    d: "Multi-stage build байхгүй бол JAR-ийн хамт Maven cache ачаалагдаж image том болно.", c: C.accent },
  ];

  learned.forEach((it, i) => {
    const col = i % 2, row = Math.floor(i / 2);
    const x = 0.6 + col * 6.3;
    const y = 1.85 + row * 1.6;
    s.addShape(pres.ShapeType.roundRect, {
      x, y, w: 5.95, h: 1.45,
      fill: { color: C.cardBg }, line: { color: C.border, width: 1 },
      rectRadius: 0.08,
    });
    s.addShape(pres.ShapeType.ellipse, {
      x: x + 0.2, y: y + 0.2, w: 0.65, h: 0.65,
      fill: { color: it.c }, line: { type: "none" },
    });
    s.addText(it.ic, {
      x: x + 0.2, y: y + 0.2, w: 0.65, h: 0.65,
      fontFace: F.head, fontSize: 22, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
    s.addText(it.t, {
      x: x + 1.0, y: y + 0.18, w: 4.85, h: 0.4,
      fontFace: F.head, fontSize: 15, bold: true, color: C.textDark,
    });
    s.addText(it.d, {
      x: x + 1.0, y: y + 0.58, w: 4.85, h: 0.8,
      fontFace: F.body, fontSize: 12, color: C.textMuted, lineSpacing: 17,
    });
  });

  slideNumber(s, 13, TOTAL);
}

// =====================================================================
// Slide 14 — Thank you
// =====================================================================
{
  const s = pres.addSlide();
  darkBg(s);

  // Big numbers / monogram block
  s.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 13.333, h: 1.4,
    fill: { color: C.primary }, line: { type: "none" },
  });
  s.addShape(pres.ShapeType.rect, {
    x: 0, y: 6.1, w: 13.333, h: 1.4,
    fill: { color: C.primary }, line: { type: "none" },
  });

  s.addText("АНХААРАЛ ТАВЬСАНД БАЯРЛАЛАА", {
    x: 0.6, y: 0.45, w: 12.1, h: 0.55,
    fontFace: F.body, fontSize: 14, bold: true,
    color: C.accent, charSpacing: 8, align: "center",
  });

  s.addText("Асуулт байна уу?", {
    x: 0.6, y: 2.3, w: 12.1, h: 1.2,
    fontFace: F.head, fontSize: 60, bold: true,
    color: C.textLight, align: "center",
  });

  s.addText("UB Дэлгүүрийн систем — Sprint 13–15 ба Project III", {
    x: 0.6, y: 3.65, w: 12.1, h: 0.5,
    fontFace: F.body, fontSize: 16, italic: true,
    color: "CADCFC", align: "center",
  });

  // Footer info chips
  const fc = [
    { t: "GitHub repo", x: 3.2 },
    { t: "docker-compose up", x: 5.85 },
    { t: "localhost:8080–8083", x: 8.7 },
  ];
  fc.forEach(c => {
    s.addShape(pres.ShapeType.roundRect, {
      x: c.x, y: 4.7, w: 2.6, h: 0.5,
      fill: { color: "FFFFFF", transparency: 88 },
      line: { color: C.accent, width: 1 },
      rectRadius: 0.25,
    });
    s.addText(c.t, {
      x: c.x, y: 4.7, w: 2.6, h: 0.5,
      fontFace: F.body, fontSize: 12, bold: true,
      color: C.textLight, align: "center", valign: "middle",
    });
  });

  s.addText("Илтгэгч: Дигий  •  Java • Microservices • Docker • CI/CD", {
    x: 0.6, y: 6.55, w: 12.1, h: 0.55,
    fontFace: F.body, fontSize: 13,
    color: C.textLight, charSpacing: 3, align: "center", valign: "middle",
  });
}

// Write
pres.writeFile({ fileName: "UB_Shop_Project_Presentation.pptx" })
  .then(name => console.log("Wrote:", name));
