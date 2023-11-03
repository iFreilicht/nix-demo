import Reveal from 'reveal.js';
import Markdown from 'reveal.js/plugin/markdown/markdown.esm';
import Highlight from 'reveal.js/plugin/highlight/highlight.esm'
import Notes from 'reveal.js/plugin/notes/notes.esm';
import shellSession from './shell-session.language';
import bashExtended from './bash-extended.language';

let deck = new Reveal({
  keyboard: {
    40: "next",
    38: "prev",
  },
  hash: true,
  transition: "none",
  history: "true",
  plugins: [Markdown, Highlight, Notes],
  highlight: {
    beforeHighlight: hljs => {
      hljs.registerLanguage("shell-session", shellSession);
    }
  },
});

deck.initialize();