const fallbackData = {
  generatedAt: "未生成",
  workflowVersion: "1.1",
  projectName: "Design Automation Workflow",
  status: { queueTotal: 0, promptTotal: 0, previewTotal: 0, registerTotal: 0, visualPassed: 0, waitingConfirm: 0 },
  assets: [],
  prompts: [],
  queue: [],
  register: [],
  previews: [],
  reports: { outputCheck: "暂无检查报告。", outputReview: "暂无审核报告。" }
};

let appData = fallbackData;
let activePrompt = null;

const $ = (selector) => document.querySelector(selector);

async function loadData() {
  if (window.WORKFLOW_DATA) {
    appData = window.WORKFLOW_DATA;
    render();
    return;
  }

  try {
    const response = await fetch("data/app-data.json", { cache: "no-store" });
    if (!response.ok) throw new Error("data not found");
    appData = await response.json();
  } catch {
    appData = fallbackData;
  }
  render();
}

function text(value, fallback = "未填写") {
  if (value === null || value === undefined || value === "") return fallback;
  return String(value);
}

function render() {
  $("#projectName").textContent = text(appData.projectName);
  $("#currentProject").textContent = text(appData.projectName);
  $("#workflowVersion").textContent = text(appData.workflowVersion, "1.1");
  $("#promptTotal").textContent = text(appData.status?.promptTotal, "0");
  $("#visualPassed").textContent = text(appData.status?.visualPassed, "0");

  renderAssets();
  renderPrompts();
  renderPreviews();
  renderRegister();
  renderQueue();
  $("#outputCheckReport").textContent = text(appData.reports?.outputCheck, "暂无输出保存检查报告。");
  $("#outputReviewReport").textContent = text(appData.reports?.outputReview, "暂无输出审核报告。");
}

function renderAssets() {
  const grid = $("#assetGrid");
  const assets = appData.assets || [];
  if (!assets.length) {
    grid.innerHTML = `<article class="card"><strong>暂无素材</strong><p>运行 deploy_ui.ps1 后会读取 00_input 文件夹。</p></article>`;
    return;
  }
  grid.innerHTML = assets.map((item) => `
    <article class="card">
      <strong>${escapeHtml(item.name)}</strong>
      <span>${escapeHtml(item.folder)} · ${escapeHtml(item.type || "file")}</span>
      <p>${escapeHtml(item.path)}</p>
    </article>
  `).join("");
}

function renderPrompts() {
  const list = $("#promptList");
  const prompts = appData.prompts || [];
  if (!prompts.length) {
    list.innerHTML = `<button type="button">暂无提示词文件</button>`;
    return;
  }
  if (!activePrompt) activePrompt = prompts[0];
  list.innerHTML = prompts.map((prompt) => `
    <button type="button" class="${prompt.name === activePrompt.name ? "active" : ""}" data-prompt="${escapeAttr(prompt.name)}">
      ${escapeHtml(prompt.name)}
    </button>
  `).join("");
  $("#activePromptName").textContent = activePrompt.name;
  $("#promptContent").textContent = activePrompt.content || "空文件";
}

function renderPreviews() {
  const grid = $("#previewGrid");
  const queue = appData.queue || [];
  const previews = appData.previews || [];
  const registers = appData.register || [];
  const reviewRows = parseReviewRows();
  if (!queue.length) {
    grid.innerHTML = `<article class="card"><strong>暂无预览队列</strong><p>运行 deploy_ui.ps1 后会读取 image_generation_queue。</p></article>`;
    return;
  }
  grid.innerHTML = queue.map((item) => {
    const preview = previews.find((entry) => entry.name === item.output_file);
    const register = registers.find((entry) => entry.id === item.id);
    const review = reviewRows.find((entry) => entry.figure === item.figure || entry.fileName === item.output_file);
    const isCompleted = Boolean(register && text(register.status, "").includes("视觉预览通过"));
    const status = isCompleted ? "视觉预览通过，待正式尺寸确认" : "待生成 / 待保存";
    return `
    <article class="preview-card">
      ${preview ? `<img src="${escapeAttr(preview.url)}" alt="${escapeAttr(preview.name)}" loading="lazy" />` : `<div class="preview-placeholder">待处理</div>`}
      <div>
        <strong>${escapeHtml(item.figure)}：${escapeHtml(item.material_name)}</strong><br />
        <small>${escapeHtml(item.output_file)}</small>
        <div class="preview-meta">
          <span>当前状态 <b>${escapeHtml(status)}</b></span>
          <span>目标尺寸 <b>${escapeHtml(item.size)}</b></span>
          <span>实际像素 <b>${escapeHtml(review?.actualSize || "待生成")}</b></span>
          <span>是否最终交付 <b>${isCompleted ? "否" : "未进入"}</b></span>
        </div>
      </div>
    </article>
  `;
  }).join("");
}

function renderRegister() {
  const filter = $("#statusFilter").value;
  const rows = (appData.register || []).filter((item) => {
    if (filter === "全部") return true;
    return text(item.status, "").includes(filter);
  });
  $("#registerTable").innerHTML = rows.map((item) => `
    <tr>
      <td>${escapeHtml(item.figure || item.id)}</td>
      <td>${escapeHtml(item.material_name)}</td>
      <td>${escapeHtml(item.file_name)}</td>
      <td><span class="status-chip">${escapeHtml(item.status)}</span></td>
      <td class="comment-cell">${escapeHtml(item.review_comment)}</td>
      <td>${escapeHtml(item.next_action)}</td>
    </tr>
  `).join("") || `<tr><td colspan="6">暂无登记记录</td></tr>`;
}

function renderQueue() {
  const rows = appData.queue || [];
  const registers = appData.register || [];
  $("#queueTable").innerHTML = rows.map((item) => `
    <tr>
      <td>${escapeHtml(item.figure || item.id)}</td>
      <td>${escapeHtml(item.material_name)}</td>
      <td>${escapeHtml(item.size)}</td>
      <td>${escapeHtml(item.orientation)}</td>
      <td>${queueStatusChip(item, registers)}</td>
      <td>${escapeHtml(item.priority)}</td>
      <td>${escapeHtml(item.notes)}</td>
    </tr>
  `).join("") || `<tr><td colspan="7">暂无队列记录</td></tr>`;
}

function queueStatusChip(item, registers) {
  const register = registers.find((entry) => entry.id === item.id);
  if (register && text(register.status, "").includes("视觉预览通过")) {
    return `<span class="status-chip">已完成</span>`;
  }
  return `<span class="status-chip waiting">待处理</span>`;
}

function parseReviewRows() {
  const report = text(appData.reports?.outputReview, "");
  return report
    .split("\n")
    .filter((line) => line.trim().startsWith("| 图") && !line.includes("---") && !line.includes("图号"))
    .map((line) => {
      const parts = line.split("|").map((part) => part.trim()).filter(Boolean);
      return {
        figure: parts[0],
        material: parts[1],
        fileName: parts[2],
        targetSize: parts[5],
        actualSize: parts[6],
        conclusion: parts[8]
      };
    });
}

function escapeHtml(value) {
  return text(value, "").replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;"
  }[char]));
}

function escapeAttr(value) {
  return escapeHtml(value).replace(/`/g, "&#96;");
}

document.addEventListener("click", (event) => {
  const promptButton = event.target.closest("[data-prompt]");
  if (promptButton) {
    activePrompt = (appData.prompts || []).find((item) => item.name === promptButton.dataset.prompt);
    renderPrompts();
  }

  const uploadButton = event.target.closest("[data-upload]");
  if (uploadButton) {
    alert(`当前 UI 是静态管理台。\n请把 ${uploadButton.dataset.upload} 文件放入真实项目的 00_input 对应文件夹，再运行 deploy_ui.ps1 刷新页面数据。`);
  }
});

$("#statusFilter").addEventListener("change", renderRegister);

$("#themeToggle").addEventListener("click", () => {
  document.body.classList.toggle("light");
  localStorage.setItem("workflow-theme", document.body.classList.contains("light") ? "light" : "dark");
});

$("#copyPrompt").addEventListener("click", async () => {
  if (!activePrompt) return;
  await navigator.clipboard.writeText(activePrompt.content || "");
  $("#copyPrompt").textContent = "已复制";
  setTimeout(() => { $("#copyPrompt").textContent = "复制"; }, 1200);
});

if (localStorage.getItem("workflow-theme") === "light") {
  document.body.classList.add("light");
}

loadData();
