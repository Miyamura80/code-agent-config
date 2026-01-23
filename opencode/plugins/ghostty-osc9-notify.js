import { exec } from "node:child_process";

const session_titles = new Map();
const session_finish_reasons = new Map();
const notified_permissions = new Set();

const ESC = "\u001b";

const emit_osc9 = (title, message) => {
  const safe_title = title || "";
  const safe_message = message || "";
  process.stdout.write(`${ESC}]9;${safe_title};${safe_message}${ESC}\\`);
};

const escape_applescript = (value) => {
  const text = value || "";
  return text.replaceAll("\\", "\\\\").replaceAll('"', '\\"');
};

const emit_notification = async (title, message) => {
  if (!title && !message) {
    return;
  }

  const safe_title = escape_applescript(title);
  const safe_message = escape_applescript(message);
  const command = `osascript -e "display notification \"${safe_message}\" with title \"${safe_title}\""`;

  await new Promise((resolve) => {
    exec(command, (error) => {
      if (error) {
        emit_osc9("", [title, message].filter(Boolean).join(" - "));
      }
      resolve();
    });
  });
};

const coerce_string = (value) => {
  if (!value) {
    return "";
  }
  if (typeof value === "string") {
    return value;
  }
  return String(value);
};

const extract_session_title = (event) => {
  return (
    event?.session?.info?.title ||
    event?.session?.title ||
    event?.info?.title ||
    event?.title ||
    ""
  );
};

const NOTIFICATION_TITLE = "👐OpenCode👐";

const normalize_text = (value) => {
  if (!value) {
    return "";
  }
  return value.replace(/^OC\s*[|\-:–—]\s*/i, "").trim();
};

const build_notification = (base_message, session_id, reason) => {
  const title = normalize_text(session_titles.get(session_id) || "");
  const clean_reason = normalize_text(reason);
  const pieces = [];

  if (base_message) {
    pieces.push(base_message);
  }

  if (title) {
    pieces.push(title);
  }

  if (clean_reason) {
    pieces.push(clean_reason);
  }

  return {
    title: NOTIFICATION_TITLE,
    message: pieces.join(" - "),
  };
};

export const GhosttyOsc9Notify = async () => {
  return {
    event: async ({ event }) => {
      if (!event?.type) {
        return;
      }

      if (event.type === "session.created" || event.type === "session.updated") {
        const session_id = event.session?.id || event.sessionID || event?.payload?.sessionID;
        const title = normalize_text(extract_session_title(event));
        if (session_id && title) {
          session_titles.set(session_id, title);
        }
      }

      if (event.type === "message.part.updated") {
        const part = event.part || event.message?.part || event?.payload?.part;
        if (part?.type === "step-finish") {
          const session_id = event.sessionID || event.session?.id || event?.payload?.sessionID;
          const reason = normalize_text(coerce_string(part.reason));
          if (session_id && reason) {
            session_finish_reasons.set(session_id, reason);
          }
        }
      }

      if (event.type === "permission.updated") {
        const permission = event.permission || event?.payload;
        const permission_id = permission?.id;
        if (permission_id && notified_permissions.has(permission_id)) {
          return;
        }
        if (permission_id) {
          notified_permissions.add(permission_id);
        }

        const session_id = permission?.sessionID || event.sessionID || event.session?.id;
        const reason = normalize_text(
          coerce_string(
            permission?.title ||
              permission?.metadata?.reason ||
              permission?.metadata?.command ||
              permission?.metadata?.tool
          )
        );

        const permission_notification = build_notification(
          "Permission needed",
          session_id,
          reason
        );
        await emit_notification(
          permission_notification.title,
          permission_notification.message
        );
      }

      if (event.type === "permission.replied") {
        const permission_id = event.permissionID || event?.payload?.permissionID;
        if (permission_id) {
          notified_permissions.delete(permission_id);
        }
      }

      if (event.type === "session.idle") {
        const session_id = event.sessionID || event.session?.id || event?.payload?.sessionID;
        const reason = session_finish_reasons.get(session_id) || "";
        const completion_notification = build_notification("", session_id, reason);
        await emit_notification(
          completion_notification.title,
          completion_notification.message
        );
        if (session_id) {
          session_finish_reasons.delete(session_id);
        }
      }
    },
  };
};
