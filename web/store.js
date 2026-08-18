export function createMemoryStorage(initial = {}) {
  const data = { ...initial };
  return {
    getItem(key) {
      return Object.prototype.hasOwnProperty.call(data, key) ? data[key] : null;
    },
    setItem(key, value) {
      data[key] = String(value);
    },
    removeItem(key) {
      delete data[key];
    },
  };
}

export function createStore(storage, key = "palpi.tasks") {
  const listeners = new Set();

  function load() {
    try {
      const raw = storage.getItem(key);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  let tasks = load();

  function persist() {
    storage.setItem(key, JSON.stringify(tasks));
    for (const listener of listeners) {
      listener(tasks);
    }
  }

  return {
    getTasks() {
      return tasks;
    },
    remainingCount() {
      return tasks.filter((task) => !task.isDone).length;
    },
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
    add(title) {
      const trimmed = String(title ?? "").trim();
      if (!trimmed) {
        return null;
      }

      const task = {
        id: crypto.randomUUID(),
        title: trimmed,
        isDone: false,
        createdAt: new Date().toISOString(),
      };
      tasks = [task, ...tasks];
      persist();
      return task;
    },
    toggle(id) {
      tasks = tasks.map((task) =>
        task.id === id ? { ...task, isDone: !task.isDone } : task,
      );
      persist();
    },
    delete(id) {
      tasks = tasks.filter((task) => task.id !== id);
      persist();
    },
  };
}
