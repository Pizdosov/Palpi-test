import assert from "node:assert/strict";
import test from "node:test";
import { createMemoryStorage, createStore } from "../store.js";

function makeStore(initial) {
  return createStore(createMemoryStorage(initial));
}

test("ignores empty titles", () => {
  const store = makeStore();
  assert.equal(store.add("   "), null);
  assert.deepEqual(store.getTasks(), []);
});

test("adds the newest task first", () => {
  const store = makeStore();
  store.add("Первая");
  store.add("Вторая");
  assert.deepEqual(
    store.getTasks().map((task) => task.title),
    ["Вторая", "Первая"],
  );
});

test("toggles and deletes a task", () => {
  const store = makeStore();
  const task = store.add("Купить молоко");
  assert.equal(store.remainingCount(), 1);

  store.toggle(task.id);
  assert.equal(store.getTasks()[0].isDone, true);
  assert.equal(store.remainingCount(), 0);

  store.delete(task.id);
  assert.deepEqual(store.getTasks(), []);
});

test("reloads saved tasks from storage", () => {
  const storage = createMemoryStorage();
  const first = createStore(storage);
  first.add("Позвонить маме");

  const reloaded = createStore(storage);
  assert.equal(reloaded.getTasks()[0].title, "Позвонить маме");
  assert.equal(reloaded.getTasks().length, 1);
});
