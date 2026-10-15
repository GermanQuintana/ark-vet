import assert from "node:assert/strict";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const expectedWrites = [
  "ark_crear_articulos_desde_documento",
  "ark_crear_compra",
  "ark_crear_compra_desde_documento",
  "ark_crear_pedido",
  "ark_emitir_pedido",
  "ark_enviar_recordatorios_email",
];

const childEnv = Object.fromEntries(
  Object.entries(process.env).filter((entry) => entry[1] !== undefined),
);
Object.assign(childEnv, {
  ARK_BASE_URL: "https://example.invalid/ark/rest",
  ARK_TENANT: "smoke-test",
  ARK_USERNAME: "smoke-test",
  ARK_PASSWORD: "smoke-test",
});

const transport = new StdioClientTransport({
  command: process.execPath,
  args: [process.env.ARK_SMOKE_SERVER ?? "./dist/index.js"],
  cwd: process.cwd(),
  env: childEnv,
});
const client = new Client({ name: "mcp-ark-smoke-test", version: "1.0.0" });

try {
  await client.connect(transport);
  const { tools } = await client.listTools();
  assert.equal(tools.length, 39, "El servidor debe publicar 39 herramientas");
  assert.ok(tools.every((tool) => tool.annotations), "Todas deben tener anotaciones MCP");

  const writes = tools
    .filter((tool) => tool.annotations?.readOnlyHint === false)
    .map((tool) => tool.name)
    .sort();
  assert.deepEqual(writes, expectedWrites);
  console.log(JSON.stringify({ total: tools.length, writes, allAnnotated: true }, null, 2));
} finally {
  await client.close();
}
