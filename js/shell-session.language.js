export default function(hljs) {
  return {
    name:"Shell Session",
    aliases:["console","shellsession"],
    contains:[
      {
        begin:/^\s{0,3}(?=[/~\w\d[\]()@\-\: ]*[ ]?[>%$#][ ]?)/, // This line uses a positive look-ahead to check that the end of the promt is in the same line. It includes spaces in the prompt.
        end:/[ ]*[>%$#][ ]?/, // End of the prompt
        excludeEnd: true, // I've excluded it from the highlight, but I'm not sure it's the case for everyone.
        contains: [
          // {
          //   className:"string", // I've used this classNames because of the color of my theme. Probably not the best.
          //   begin:/^[\w\d[\]()@\- ]*/, // Start of the prompt, usualy user@hostname
          // },
          // {
          //   begin:/\:/,
          // },
          {
            className:"meta",
            excludeEnd: true,
            begin:/~/, // Second part of the prompt, usually where the current directory is shown.
            end:/\ /, // In my case, there is a space before the end of the prompt.
          },
        ],
        starts:{
          end:/[^\\](?=\s*$)/,
          subLanguage:"bash"
        }
      }
    ]
  }
}