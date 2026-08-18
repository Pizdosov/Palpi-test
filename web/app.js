import { createStore } from "./store.js";

const store = createStore(window.localStorage);
const listEl = document.querySelector("#task-list");
const emptyEl = document.querySelector("#empty-state");
const noteEl = document.querySelector("#remaining-note");
const formEl = document.querySelector("#add-form");
const inputEl = document.querySelector("#task-input");
const submitEl = document.querySelector("#add-button");
const clockEl = document.querySelector("#clock");
const filterButtons = [...document.querySelectorAll("[data-filter]")];

let filter = "all";

function remainingText(count) {
  if (count === 0) return "Все задачи выполнены";
  if (count === 1) return "Осталась 1 задача";
  if (count >= 2 && count <= 4) return `Осталось ${count} задачи`;
  return `Осталось ${count} задач`;
}

function visibleTasks(tasks) {
  if (filter === "active") return tasks.filter((task) => !task.isDone);
  if (filter === "done") return tasks.filter((task) => task.isDone);
  return tasks;
}

function render() {
  const tasks = store.getTasks();
  const visible = visibleTasks(tasks);

  listEl.innerHTML = "";
  emptyEl.hidden = tasks.length > 0 && visible.length > 0;
  listEl.hidden = visible.length === 0;
  noteEl.hidden = tasks.length === 0;

  if (tasks.length === 0) {
    emptyEl.innerHTML = "<strong>Список пуст</strong>Напишите задачу внизу — например, «Купить молоко».";
  } else if (visible.length === 0) {
    emptyEl.innerHTML = "<strong>Здесь пусто</strong>В этом фильтре пока нет задач.";
  }

  for (const task of visible) {
    const row = document.createElement("div");
    row.className = `row${task.isDone ? " done" : ""}`;

    const toggle = document.createElement("button");
    toggle.className = `task${task.isDone ? " done" : ""}`;
    toggle.type = "button";
    toggle.setAttribute("aria-pressed", String(task.isDone));
    toggle.setAttribute(
      "aria-label",
      `${task.title}, ${task.isDone ? "выполнено" : "не выполнено"}`,
    );
    toggle.innerHTML = `<span class="check" aria-hidden="true"></span><span class="title"></span>`;
    toggle.querySelector(".title").textContent = task.title;
    toggle.addEventListener("click", () => store.toggle(task.id));

    const remove = document.createElement("button");
    remove.className = "delete";
    remove.type = "button";
    remove.textContent = "Удалить";
    remove.addEventListener("click", () => store.delete(task.id));

    row.append(toggle, remove);
    listEl.append(row);
  }

  noteEl.textContent = remainingText(store.remainingCount());
  submitEl.disabled = inputEl.value.trim() === "";
}

function updateClock() {
  const now = new Date();
  clockEl.textContent = new Intl.DateTimeFormat("ru-RU", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(now);
}

filterButtons.forEach((button) => {
  button.addEventListener("click", () => {
    filter = button.dataset.filter;
    filterButtons.forEach((item) => {
      item.setAttribute("aria-pressed", String(item === button));
    });
    render();
  });
});

formEl.addEventListener("submit", (event) => {
  event.preventDefault();
  if (!store.add(inputEl.value)) return;
  inputEl.value = "";
  filter = "all";
  filterButtons.forEach((item) => {
    item.setAttribute("aria-pressed", String(item.dataset.filter === "all"));
  });
  render();
});

inputEl.addEventListener("input", () => {
  submitEl.disabled = inputEl.value.trim() === "";
});

store.subscribe(render);
updateClock();
setInterval(updateClock, 30_000);
render();
