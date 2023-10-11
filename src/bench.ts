import { hashLeavesGPU } from "./webgpu";
import { hashLeavesCPU } from "./cpu";
function randU32(): number {
  return Math.floor(Math.random() * 0x100000000);
}
const GoldilocksPrime = BigInt("0xfffffffe00000001");

type LeafGenerator = (index: number) => bigint[];

interface IBenchmarkConfig {
  leafGenerator: LeafGenerator;
  samples: number;
  treeHeight: number;
  disableCPU: boolean;
}

function randGoldilocksHash(_: number): bigint[] {
  // not cryptographically secure, just for generating test inputs
  const bu64 = new BigUint64Array(
    new Uint32Array([
      randU32(),
      randU32(),
      randU32(),
      randU32(),
      randU32(),
      randU32(),
      randU32(),
      randU32()
    ]).buffer
  );
  return [
    bu64[0] % GoldilocksPrime,
    bu64[1] % GoldilocksPrime,
    bu64[2] % GoldilocksPrime,
    bu64[3] % GoldilocksPrime
  ];
}
function sequentialLeafGenerator(i: number): bigint[] {
  return [BigInt(i), BigInt(i), BigInt(i), BigInt(i)];
}
function genLeaves(
  leafGenerator: LeafGenerator,
  treeHeight: number
): bigint[][] {
  const numLeaves = 2 ** treeHeight;
  const leaves = [];
  for (let i = 0; i < numLeaves; i++) {
    leaves[i] = leafGenerator(i);
  }
  return leaves;
}
function compareHash(a: bigint[], b: bigint[]): boolean {
  return a[0] === b[0] && a[1] === b[1] && a[2] === b[2] && a[3] === b[3];
}
async function benchCPUvsGPU({
  leafGenerator,
  treeHeight,
  samples,
  disableCPU
}: IBenchmarkConfig) {
  const leaves = genLeaves(leafGenerator, treeHeight);
  let hash: bigint[] = [];
  let cpuTotalTime = 0;
  let gpuTotalTime = 0;
  for (let i = 0; i < samples; i++) {
    const gpu = await hashLeavesGPU(leaves);
    if (i === 0) {
      hash = gpu.result;
    }
    gpuTotalTime += gpu.duration;

    if (!disableCPU) {
      const cpu = hashLeavesCPU(leaves);
      cpuTotalTime += cpu.duration;

      if (!compareHash(cpu.result, gpu.result)) {
        throw new Error(
          "cpu and gpu returned different merkle roots for the same input leaves!"
        );
      }
    }
  }

  return {
    cpu: (disableCPU ? "N/A " : cpuTotalTime / samples) as any,
    gpu: gpuTotalTime / samples,
    root: hash,
    leaves
  };
}

export type { IBenchmarkConfig };

export { benchCPUvsGPU, randGoldilocksHash, sequentialLeafGenerator };
