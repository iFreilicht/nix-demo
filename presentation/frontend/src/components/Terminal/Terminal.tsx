import React from "react";

import { useXTerm } from "./useXTerm";
import { useSteps } from "spectacle";

type TerminalProps = {
  commands: string[];
};

function Terminal({ commands }: TerminalProps) {
  const termParentRef = React.useRef<HTMLDivElement>(null);
  const termRef = useXTerm(termParentRef);

  const [highestStep, setHighestStep] = React.useState(-1);

  const { step, placeholder: stepMarker } = useSteps(commands.length);

  React.useEffect(() => {
    // Don't run a command if we've already run it
    if (isNaN(step) || highestStep >= commands.length || step <= highestStep)
      return;

    if (termRef.current === null) return;

    termRef.current.exec(commands[step]);
    setHighestStep(highestStep + 1);
  }, [commands, highestStep, step, termRef]);

  const handleClear = () => {
    if (termRef.current === null) {
      return;
    }
    const term = termRef.current;

    term.xterm.clear();
  };

  return (
    <div>
      {stepMarker}
      <div ref={termParentRef}></div>
      <button onClick={handleClear}>Clear</button>
    </div>
  );
}

export default Terminal;
