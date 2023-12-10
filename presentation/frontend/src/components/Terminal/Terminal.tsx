import React, { useState } from "react";

import { Terminal as XTerm } from "xterm";
import { AttachAddon } from "@xterm/addon-attach";
import { HOST, PORT } from "../../../../shared/src/constants";

const initTerminal = async (): Promise<XTerm> => {
  const term = new XTerm({ cols: 80, rows: 24, fontSize: 24 });

  term.onLineFeed(() => console.log("line feed!"));

  const res = await fetch(
    `http://${HOST}:${PORT}/terminals?cols=` + term.cols + "&rows=" + term.rows,
    { method: "POST" }
  );
  const pid = await res.text();
  console.log(`Opened terminal with pid ${pid}`);

  const socketURL = `ws://${HOST}:${PORT}/terminals/${pid}`;

  const socket = new WebSocket(socketURL);
  const addons = {
    attach: new AttachAddon(socket, { bidirectional: true }),
  };
  term.loadAddon(addons.attach);

  return term;
};

function Terminal() {
  const termParentRef = React.useRef<HTMLDivElement>(null);

  const termRef = React.useRef<XTerm | null>(null);
  const [termStatus, setTermStatus] = useState("none");

  React.useEffect(() => {
    if (
      termStatus !== "none" ||
      termRef.current !== null ||
      termParentRef.current === null
    )
      return;
    let abort = false;

    initTerminal().then((term) => {
      if (abort) {
        term.dispose();
        return;
      }

      termRef.current = term;
      setTermStatus("ready");
    });

    return () => {
      abort = true;
    };
  }, [termStatus, termParentRef]);

  React.useEffect(() => {
    if (termStatus !== "ready" || !termRef.current || !termParentRef.current)
      return;

    setTermStatus("active");
    termRef.current.open(termParentRef.current);
  }, [termStatus, termRef, termParentRef]);

  const handleClear = () => {
    if (termRef.current === null) {
      return;
    }
    const term = termRef.current;

    term.clear();
  };

  return (
    <>
      <div ref={termParentRef}></div>
      <button onClick={handleClear}>Clear</button>
    </>
  );
}

export default Terminal;
