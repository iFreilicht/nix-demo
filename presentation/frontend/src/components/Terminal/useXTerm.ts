import React, { useState } from "react";

import { Terminal as XTerm } from "xterm";
import "xterm/css/xterm.css";
import { AttachAddon } from "@xterm/addon-attach";
import { HOST, PORT } from "../../../../shared/src/constants";

const BASE_PATH = `http://${HOST}:${PORT}`;

type EnhancedXTerm = {
  xterm: XTerm;
  // Actually sends the command to the server to be executed. XTerm.write only writes on the client side
  exec: (command: string) => Promise<void>;
};
const initTerminal = async (rows: number): Promise<EnhancedXTerm> => {
  const xterm = new XTerm({ cols: 80, rows, fontSize: 24 });

  xterm.onLineFeed(() => console.log("line feed!"));

  const res = await fetch(
    `${BASE_PATH}/terminals?cols=${xterm.cols}&rows=${xterm.rows}`,
    { method: "POST" }
  );
  const pid = await res.text();
  console.log(`Opened terminal with pid ${pid}`);

  const socketURL = `ws://${HOST}:${PORT}/terminals/${pid}`;

  const socket = new WebSocket(socketURL);
  const addons = {
    attach: new AttachAddon(socket, { bidirectional: true }),
  };
  xterm.loadAddon(addons.attach);

  const exec = async (command: string) => {
    const body = JSON.stringify({ command });
    console.log({ body });
    await fetch(`${BASE_PATH}/terminals/${pid}/exec`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body,
    });
  };

  return { xterm, exec };
};

export function useXTerm(
  parentRef: React.RefObject<HTMLDivElement>,
  rows: number = 27 /* This default works for an empty slide with nothing but the terminal on it */
): React.RefObject<EnhancedXTerm | null> {
  const termRef = React.useRef<EnhancedXTerm | null>(null);
  const [termStatus, setTermStatus] = useState("none");

  React.useEffect(() => {
    if (
      termStatus !== "none" ||
      termRef.current !== null ||
      parentRef.current === null
    )
      return;
    let abort = false;

    initTerminal(rows).then((term) => {
      if (abort) {
        term.xterm.dispose();
        return;
      }

      termRef.current = term;
      setTermStatus("ready");
    });

    return () => {
      abort = true;
    };
  }, [termStatus, parentRef, rows]);

  React.useEffect(() => {
    if (termStatus !== "ready" || !termRef.current || !parentRef.current)
      return;

    setTermStatus("active");
    termRef.current.xterm.open(parentRef.current);
  }, [termStatus, termRef, parentRef]);

  return termRef;
}
