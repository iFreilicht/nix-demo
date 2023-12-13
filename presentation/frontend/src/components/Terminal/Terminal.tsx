import React from "react";

import { useXTerm } from "./useXTerm";

function Terminal() {
  const termParentRef = React.useRef<HTMLDivElement>(null);

  const termRef = useXTerm(termParentRef);

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
