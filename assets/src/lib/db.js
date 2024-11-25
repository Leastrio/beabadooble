import { pad } from './shared.svelte.js';

let db_connection;

export function open_db() {
  return new Promise((resolve) => {
    const request = indexedDB.open("beabadooble", 2);
    request.onupgradeneeded = (event) => {
      const db = event.target.result;

      let old_data = [];
      
      if (db.objectStoreNames.contains("history")) {
        const transaction = event.target.transaction;
        const obj_store = transaction.objectStore("history");

        const get_all_request = obj_store.getAll();
        get_all_request.onsuccess = () => {
          old_data = get_all_request.result;

          db.deleteObjectStore("history");
          const new_store = db.createObjectStore("history", {keyPath: "day_id"});
          new_store.createIndex("date", "date");

          event.target.transaction.oncomplete = () => {
            const obj_store = db.transaction("history", "readwrite").objectStore("history");

            old_data.forEach((item) => {
              new_obj = {
                day_id: item.song_id,
                date: `${item.date.year}-${pad(item.date.month)}-${pad(item.date.day)}`,
                guesses: item.guesses.flatMap(({input, status}) => {
                    if (status === "empty" || status === "current") return [];
                    return {
                      input: input === "nil" ? "" : input,
                      status: status
                    }
                  })
              };
              obj_store.add(new_obj);
            });
          };
        };
      } else {
        const new_store = db.createObjectStore("history", {keyPath: "day_id"});
        new_store.createIndex("date", "date");
      }
    };

    request.onsuccess = (event) => {
      db_connection = event.target.result;

      const cursor_req = db_connection.transaction("history", "readonly").objectStore("history").openCursor(null, "prev");
      cursor_req.onsuccess = (event) => {
        const item = event.target.result;
        if (item) {
          resolve(item.value);
        } else {
          resolve(null);
        }
      }
    };
  });
}

export function upsert_state(data) {
  if (db_connection && data.day_id !== 0) {
    db_connection.transaction("history", "readwrite").objectStore("history").put(data);
  }
}
