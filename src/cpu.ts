import { twoToOne } from "poseidon2/goldilocks-12";

function hashLeavesCPU(leaves: bigint[][]) {
  const start = performance.now();
  let current = leaves;
  const height = Math.floor(Math.log2(leaves.length));
  for (let h = 0; h < height; h++) {
    const newCur = [];
    for (let i = 0; i < current.length; i += 2) {
      newCur[Math.round(i / 2)] = twoToOne(current[i], current[i + 1]);
    }
    current = newCur;
  }
  const end = performance.now();
  return { result: current[0], duration: end - start };
}

export { hashLeavesCPU };
