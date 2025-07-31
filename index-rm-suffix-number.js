const fs = require("fs").promises;

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.error("Usage: node index-rm-number.js <sql-file>");
    process.exit(1);
  }

  const sql = await fs.readFile(args[0], "utf8");
  const lines = sql.split("\n");
  const processedLines = lines.map((line) => {
    if (
      line.trim().startsWith("CREATE INDEX") ||
      line.includes("RENAME INDEX") ||
      line.includes("DROP INDEX")
    ) {
      return line.replace(/`(.[^_\d]+)\d+`/g, "`$1`");
    }
    return line;
  });
  const result = processedLines.join("\n");
  console.log(result);
}

main();
