import { useState, useEffect } from "react";
import {
  benchCPUvsGPU,
  sequentialLeafGenerator,
  randGoldilocksHash
} from "./bench";
import "./styles.css";
import QEDLogo from "./logo";
interface IBenchmarkResult {
  cpu: number;
  gpu: number;
  root: bigint[];
  leaves: bigint[][];
}
function naIfNaN(x: any): string | number {
  if (typeof x === "number" && !isNaN(x)) {
    return x;
  } else {
    return "N/A";
  }
}
export default function App() {
  const [treeHeight, setTreeHeight] = useState(16);
  const [hasRanWarmUp, setHasRanWarmUp] = useState(false);

  const [printLeaves, setPrintLeaves] = useState(false);
  const [useRandomLeaves, setUseRandomLeaves] = useState(true);
  const [result, setResult] = useState<IBenchmarkResult | null>(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [disableCPU, setDisableCPU] = useState(false);
  useEffect(() => {
    if (!hasRanWarmUp) {
      setHasRanWarmUp(true);
      setLoading(true);
      benchCPUvsGPU({
        leafGenerator: sequentialLeafGenerator,
        treeHeight: 1,
        disableCPU: true,
        samples: 1
      })
        .then((x) => {
          setLoading(false);
        })
        .catch(console.error);
    }
  }, [hasRanWarmUp]);
  return (
    <div className="App">
      <hr />
      <h1>Poseidon2 Merkle Hasher</h1>
      <h2>CPU vs WebGPU Benchmark</h2>
      <hr />
      <div className="ctrls">
        <div>
          <label className="treeHeightRow">
            <span>Merkle Tree Height(1-28):</span>
            <input
              type="number"
              min="1"
              max="24"
              step="1"
              placeholder="tree height"
              value={treeHeight}
              disabled={loading}
              onChange={(e) => setTreeHeight(parseInt(e.target.value + "", 10))}
            />
          </label>
        </div>

        <div className="checkProps">
          <label>
            Random Leaves?
            <input
              type="checkbox"
              checked={useRandomLeaves}
              disabled={loading}
              onChange={(e) => setUseRandomLeaves(e.target.checked)}
            />
          </label>
          <span> | </span>
          <label>
            Disable CPU (For large tree heights)
            <input
              type="checkbox"
              checked={disableCPU}
              disabled={loading}
              onChange={(e) => setDisableCPU(e.target.checked)}
            />
          </label>
          <span> | </span>
          <label>
            Show Leaves?
            <input
              type="checkbox"
              checked={printLeaves}
              disabled={loading}
              onChange={(e) => setPrintLeaves(e.target.checked)}
            />
          </label>
        </div>

        <div className="btnCon">
          <button
            className="benchmarkBtn"
            disabled={loading}
            onClick={() => {
              setLoading(true);
              setResult(null);
              setErrorMessage("");
              benchCPUvsGPU({
                leafGenerator: useRandomLeaves
                  ? randGoldilocksHash
                  : sequentialLeafGenerator,
                treeHeight,
                disableCPU,
                samples: 1
              })
                .then((r) => {
                  setResult(r);
                  setLoading(false);
                })
                .catch((err) => {
                  console.error(err);
                  setErrorMessage(err + "");
                });
            }}
          >
            {loading ? "Running Benchmark..." : "Start Benchmark"}
          </button>
        </div>
      </div>
      {errorMessage ? <div className="errorMessage">{errorMessage}</div> : null}
      {result ? (
        <div className="results">
          <div className="resultCol">
            <div className="resultCell">
              CPU Time: {result.cpu + "ms"} (Per 2-to-1 Hash:{" "}
              {naIfNaN(result.cpu / (result.leaves.length - 1))} ms)
            </div>
          </div>
          <div className="resultCol">
            <div className="resultCell">
              GPU Time: {result.gpu + "ms"} (Per 2-to-1 Hash:{" "}
              {result.gpu / (result.leaves.length - 1)} ms)
            </div>
          </div>
          {typeof result.cpu === "number" ? (
            <div className="speedCompare">
              <div className="speedText">
                WebGPU is <b>{(result.cpu / result.gpu).toFixed(2)}x</b> faster
                than CPU
              </div>
            </div>
          ) : null}
          <div className="resultCol">
            <div className="resultCell">
              Number of Leafs: {result.leaves.length}
            </div>
            <div className="resultCell">
              Root: <div>{result.root.map((x) => x + "").join(", ")}</div>
            </div>
          </div>
          {printLeaves ? (
            <div className="leavesCon">
              <textarea
                className="leavesTa"
                placeholder="Leaves..."
                value={result.leaves
                  .map(
                    (l, i) =>
                      `leaf[${i}] = [${l.map((x) => x + "").join(", ")}]`
                  )
                  .join("\n")}
              ></textarea>
            </div>
          ) : null}
        </div>
      ) : null}
      <hr className="bottomHr" />
      <a href="https://qedprotocol.com" target="_blank" rel="noreferrer">
        <QEDLogo className="qedLogo" height="40" />
      </a>
    </div>
  );
}
