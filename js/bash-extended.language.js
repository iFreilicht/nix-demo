export default function(hljs) {
  const bashx = hljs.getLanguage('bash')

  bashx.name="Shell with more keywords",
  bashx.aliases=["shx","bashx","zshx"],
  bashx.supersetOf = "bash";
  return bashx
}