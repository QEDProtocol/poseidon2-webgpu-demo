
/*
MIT License

Copyright (c) 2023 Zero Knowledge Labs Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

alias GoldilocksField = vec2<u32>;
alias PoseidonState = array<GoldilocksField, 12>;
alias PoseidonHashOut = array<GoldilocksField, 4>;


const ZERO = GoldilocksField(0u, 0u);
const ONE = GoldilocksField(1u, 0u);
const TWO = GoldilocksField(2u, 0u);
const FOUR = GoldilocksField(4u, 0u);


// [Poseidon2 Constants] Start
const MAT_DIAG12_M_1 = array<GoldilocksField, 12>(GoldilocksField(0x23ba92ffu,0xc3b6c08eu), GoldilocksField(0x4a324fb5u,0xd84b5de9u), GoldilocksField(0x5b35b84eu,0xd0c371cu), GoldilocksField(0xe7188036u,0x7964f570u), GoldilocksField(0xd996604au,0x5daf18bbu), GoldilocksField(0xb9595256u,0x6743bc47u), GoldilocksField(0x2c59bb6fu,0x5528b936u), GoldilocksField(0x7127b68au,0xac45e25bu), GoldilocksField(0xfbb606b4u,0xa2077d7du), GoldilocksField(0xaee378adu,0xf3faac6fu), GoldilocksField(0x1545e882u,0xc6388b5u), GoldilocksField(0x44917b5fu,0xd27dbb69u));

const RC12 = array<array<GoldilocksField, 12>, 30>(
  array<GoldilocksField, 12>(GoldilocksField(0xba214f46u,0x13dcf33au), GoldilocksField(0xa1da6d83u,0x30b3b654u), GoldilocksField(0xa6159b56u,0x1fc634adu), GoldilocksField(0x4dc03466u,0x93745996u), GoldilocksField(0xa7949924u,0xedd2ef2cu), GoldilocksField(0xe0e22f68u,0xede9affdu), GoldilocksField(0xbac9282du,0x8515b9d6u), GoldilocksField(0xe9e900d8u,0x6b5c07b4u), GoldilocksField(0x838c8a08u,0x1ec66368u), GoldilocksField(0x80d1fbabu,0x9042367du), GoldilocksField(0x4a3c3799u,0x40028356u), GoldilocksField(0x66bca75eu,0x4a00be04u)),
  array<GoldilocksField, 12>(GoldilocksField(0x58e3817fu,0x7913beeeu), GoldilocksField(0x32237d90u,0xf545e885u), GoldilocksField(0x36042005u,0x22f8cb87u), GoldilocksField(0x247a2623u,0x6f04990eu), GoldilocksField(0xa37c38cdu,0xfe22e87bu), GoldilocksField(0x5ffe2815u,0xd20e32c8u), GoldilocksField(0x4048fe73u,0x11722767u), GoldilocksField(0x98a6b145u,0x4e9fb7eau), GoldilocksField(0x2b8af08bu,0xe0866c23u), GoldilocksField(0x16884964u,0xbbc779u), GoldilocksField(0x990d7116u,0x7031c0fbu), GoldilocksField(0xcf35108fu,0x240a9e87u)),
  array<GoldilocksField, 12>(GoldilocksField(0xa12244b3u,0x2e6363a5u), GoldilocksField(0xd1b5011cu,0x5e1c3787u), GoldilocksField(0x2a196e8bu,0x4132660eu), GoldilocksField(0x8d3d4327u,0x3a013b64u), GoldilocksField(0x9888ea43u,0xf79839f4u), GoldilocksField(0xbafe1439u,0xfe85658eu), GoldilocksField(0xa14240bdu,0xb6889825u), GoldilocksField(0x5541382bu,0x57845360u), GoldilocksField(0xf6b63ce9u,0x4508cda8u), GoldilocksField(0x48684c91u,0x9c3ef358u), GoldilocksField(0x3c87178cu,0x812bde2u), GoldilocksField(0x7f722c14u,0xfe49638fu)),
  array<GoldilocksField, 12>(GoldilocksField(0xe885cbf5u,0x8e3f688cu), GoldilocksField(0xf746a87du,0xb8e110acu), GoldilocksField(0x3a6dabefu,0xb4b2e897u), GoldilocksField(0xa3d462ecu,0x9e714c5du), GoldilocksField(0x3d3d0c15u,0x6438f903u), GoldilocksField(0xf1a27199u,0x24312f7cu), GoldilocksField(0x47acbf71u,0x23f843bbu), GoldilocksField(0x34be9f01u,0x9183f11au), GoldilocksField(0xb9d45dbfu,0x839062fbu), GoldilocksField(0x6c2e43fau,0x24b56e7eu), GoldilocksField(0x1c962a72u,0xe1683da6u), GoldilocksField(0x1a19bfa7u,0xa95c6397u)),
  array<GoldilocksField, 12>(GoldilocksField(0xa75d4316u,0x4adf842au), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xaa4ab4ebu,0xf8fbb871u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xb2dd6aebu,0x68e85b6eu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x2d270380u,0x7a0b06bu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xbd282de4u,0xd94e0228u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x250c5278u,0x8bdd91d3u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x8bba778fu,0x209c68b8u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xb77f3877u,0xb5e18cdau), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x8da93fau,0xb296a3e8u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xa11a327eu,0x8370ecbdu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x3775dad8u,0x3f907528u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x23c6aa84u,0xb78095bbu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x72ad4e5fu,0x3f36b9feu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xb10b553u,0x69bc9678u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x2eb7b881u,0x3f1d341fu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x15838818u,0x4e939e98u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xe2a31604u,0xda366b3au), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x7287d509u,0xbc89db1eu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xf9ef5659u,0x6102f411u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x7ac1f0abu,0x58725c5eu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x798883e7u,0xdf5856cu), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xda4c961bu,0xf7bb62a8u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u), GoldilocksField(0x0u,0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x4882a24du,0xc68be7c9u), GoldilocksField(0x5cdaedd9u,0xaf996d5du), GoldilocksField(0xe7daf6a5u,0x9717f025u), GoldilocksField(0x6e7216f4u,0x6436679eu), GoldilocksField(0x47af267u,0x8a223d99u), GoldilocksField(0xa133ba9au,0xbb512e35u), GoldilocksField(0x7671aa03u,0xfbbf4409u), GoldilocksField(0xf6811e61u,0xf04058ebu), GoldilocksField(0x3fac7ffbu,0x5cca8470u), GoldilocksField(0x5de6469fu,0x9b55c794u), GoldilocksField(0x808e934fu,0x8e05bf09u), GoldilocksField(0x876307d7u,0x2ea900deu)),
  array<GoldilocksField, 12>(GoldilocksField(0xb38dfb89u,0x7748fff2u), GoldilocksField(0xdd3b5d81u,0x6b99a676u), GoldilocksField(0x27cf7c13u,0xac4bb7c6u), GoldilocksField(0xe9e2f5bau,0xadb6ebe5u), GoldilocksField(0xafa24ae3u,0x2d33378cu), GoldilocksField(0x7543f8c2u,0x1e5b7380u), GoldilocksField(0xbfebb10fu,0x9208814u), GoldilocksField(0xbb5b93ddu,0x782e64b6u), GoldilocksField(0xac90b50fu,0xadd5a48eu), GoldilocksField(0x736ea4b1u,0xadd4c54cu), GoldilocksField(0xed817fd8u,0xd58dbb86u), GoldilocksField(0x33f34dddu,0x6d5ed1a5u)),
  array<GoldilocksField, 12>(GoldilocksField(0xe36b7cb9u,0x28686aa3u), GoldilocksField(0x76689f36u,0x591abd34u), GoldilocksField(0x78f13875u,0x47d7666u), GoldilocksField(0x625f5b49u,0xa2a11112u), GoldilocksField(0xf8304958u,0x21fd10a3u), GoldilocksField(0x443b0280u,0xf9b40711u), GoldilocksField(0xb2bde88eu,0xd2697eb8u), GoldilocksField(0x51731b3fu,0x3493790bu), GoldilocksField(0x73764023u,0x11caf9ddu), GoldilocksField(0x2878164eu,0x7acfb8f7u), GoldilocksField(0x23cefc26u,0x744ec4dbu), GoldilocksField(0x422c6340u,0x1e00e58fu)),
  array<GoldilocksField, 12>(GoldilocksField(0x6a62ddau,0x21dd28d9u), GoldilocksField(0x5f465b5fu,0xf32a46abu), GoldilocksField(0x1f3f7e6bu,0xbfce1320u), GoldilocksField(0xdb5304e2u,0xf30d2e7au), GoldilocksField(0xabad48e9u,0xecdf4ee4u), GoldilocksField(0x2d395019u,0xf94e8218u), GoldilocksField(0x44d887c5u,0x4ee52e37u), GoldilocksField(0xac0083b2u,0xa1341c7cu), GoldilocksField(0xc30c834au,0x2302fb26u), GoldilocksField(0x273bf7d3u,0xaea3c587u), GoldilocksField(0x61823ec7u,0xf798e249u), GoldilocksField(0xe9a2cd94u,0x962deba3u))
);
// [Poseidon2 Constants] End


// [GoldilocksField Arithmetic] Start
/*
 Golidlocks field multiplication code derived from https://github.com/recmo/proto-goldilocks-webgpu/blob/cc6ce5d2df8a20ba89484a49f82b0037f8fd5676/shader/goldilocks.wgsl#L50
 However, Recmo's add function doesn't handle overflows properly so we have implemented a our own 
 field addition function which handles overflows/modulo properly using 96 bit arithmetic
*/
fn hadd(a:u32, b:u32) -> u32 {
  return (a >> 1u) + (b >> 1u) + ((a & b) & 1u);
}

fn mul64(a:u32, b:u32) -> vec2<u32>{
  // Split into 16 bit parts
  var a0 = (a << 16u) >> 16u;
  var a1 = a >> 16u;
  var b0 = (b << 16u) >> 16u;
  var b1 = b >> 16u;

  // Compute 32 bit half products
  // Each of these is at most 0xfffe0001
  var a0b0 = a0 * b0;
  var a0b1 = a0 * b1;
  var a1b0 = a1 * b0;
  var a1b1 = a1 * b1;

  // Sum the half products
  var r: vec2<u32>;
  r.x = a0b0 + (a1b0 << 16u) + (a0b1 << 16u);
  r.y = a1b1 + (hadd((a0b0 >> 16u) + a0b1, a1b0) >> 15u);
  return r;
}

fn mul128(a: vec2<u32>, b: vec2<u32>) -> vec4 <u32>{
  // Compute 64 bit half products
  // Each of these is at most 0xfffffffe00000001
  
  var a0b0 = mul64(a.x, b.x);
  var a0b1 = mul64(a.x, b.y);
  var a1b0 = mul64(a.y, b.x);
  var a1b1 = mul64(a.y, b.y);

  var r = vec4 <u32>(a0b0, a1b1);

  // Add a0b1
  r.y += a0b1.x;
  if (r.y<a0b1.x) {
    a0b1.y += 1u; // Can not overflow
  }
  r.z += a0b1.y;
  if (r.z<a0b1.y) {
    r.w += 1u;
  }

  // Add a1b0
  r.y += a1b0.x;
  if (r.y<a1b0.x) {
    a1b0.y += 1u; // Can not overflow
  }
  r.z += a1b0.y;
  if (r.z<a1b0.y) {
    r.w += 1u;
  }

  return r;
}


fn reduce(n: vec4 <u32>) -> vec2<u32>{
  // Compute 
  // n.x + n.y * 2^32 + n.z * 2^64 + n.w * 2^96 mod p
  // which equals
  // n.x - n.z - n.w + (n.y + n.z) * 2^32 mod p

  var r = n.xy;

  // subtract n.z
  if (r.x<n.z) {
    if (r.y == 0u) {
      // Add p
      r.x += 1u; // Can not overflow
      r.y = 0xffffffffu;
    }
    r.y -= 1u;
  }
  r.x -= n.z;

  // subtract n.w
  if (r.x<n.w) {
    if (r.y == 0u) {
      // Add p
      r.x += 1u; // Can not overflow
      r.y = 0xffffffffu;
    }
    r.y -= 1u;
  }
  r.x -= n.w;

  // Add n.z * 2^32
  r.y += n.z;
  if (r.y<n.z) {
    // Add 2**64 mod p = 0xffffffff
    r.x += 0xffffffffu;
    if (r.x<0xffffffffu) {
      r.y += 1u; // Can not overflow
    }
  }

  // Reduce mod p
  if (r.y == 0xffffffffu && r.x != 0u) {
    r.y = 0u;
    r.x -= 1u; // Can not underflow
  }

  return r;
}


fn reduce96(n: vec3 <u32>) -> vec2<u32>{
  // use 96 bit reduction for addition

  var r = n.xy;

  // subtract n.z
  if (r.x<n.z) {
    if (r.y == 0u) {
      // Add p
      r.x += 1u; // Can not overflow
      r.y = 0xffffffffu;
    }
    r.y -= 1u;
  }
  r.x -= n.z;

  // Add n.z * 2^32
  r.y += n.z;
  if (r.y<n.z) {
    // Add 2**64 mod p = 0xffffffff
    r.x += 0xffffffffu;
    if (r.x<0xffffffffu) {
      r.y += 1u; // Can not overflow
    }
  }

  // Reduce mod p
  if (r.y == 0xffffffffu && r.x != 0u) {
    r.y = 0u;
    r.x -= 1u; // Can not underflow
  }

  return r;
}

fn mul(a: GoldilocksField, b: GoldilocksField) -> GoldilocksField {
  return reduce(mul128(a, b));
}

fn add(a: GoldilocksField, b: GoldilocksField) -> GoldilocksField {
  let lower = a.x + b.x;
  let upper = a.y + b.y + select(0u, 1u, lower<a.x);
  return reduce96(vec3 <u32>(lower,upper,  select(0u, 1u, upper<a.y)));
}

fn add3(a: GoldilocksField, b: GoldilocksField, c: GoldilocksField) -> GoldilocksField {
  return add(add(a, b), c);
}

fn pow7(x: GoldilocksField) -> GoldilocksField {
  let cube = mul(mul(x, x), x);
  return mul(mul(cube, cube), x);
}
// [GoldilocksField Arithmetic] End


// [Poseidon2] Start

// END ARITHMETIC 

// [Poseidon2] Start

// using private varaible so we don't have to keep copying around the permutation state
var<private> input: PoseidonState;


fn poseidon2_matmulExternal_h(offset: u32) {
  let h0 = add(input[offset], input[offset + 1]);
  let h1 = add(input[offset + 2], input[offset + 3]);
  let h2 = add3(input[offset + 1], input[offset + 1], h1);
  let h3 = add3(input[offset + 3], input[offset + 3], h0);
  let h4 = add(mul(h1, FOUR), h3);
  let h5 = add(mul(h0, FOUR), h2);
  let h6 = add(h3, h5);
  let h7 = add(h2, h4);

  input[offset] = h6;
  input[offset + 1] = h5;
  input[offset + 2] = h7;
  input[offset + 3] = h4;
}
fn poseidon2_matmulExternal() {
  poseidon2_matmulExternal_h(0);
  poseidon2_matmulExternal_h(4);
  poseidon2_matmulExternal_h(8);
  let s0 = add3(input[0], input[4], input[8]);
  let s1 = add3(input[1], input[5], input[9]);
  let s2 = add3(input[2], input[6], input[10]);
  let s3 = add3(input[3], input[7], input[11]);
  input[0] = add(input[0], s0);
  input[1] = add(input[1], s1);
  input[2] = add(input[2], s2);
  input[3] = add(input[3], s3);
  input[4] = add(input[4], s0);
  input[5] = add(input[5], s1);
  input[6] = add(input[6], s2);
  input[7] = add(input[7], s3);
  input[8] = add(input[8], s0);
  input[9] = add(input[9], s1);
  input[10] = add(input[10], s2);
  input[11] = add(input[11], s3);
}

fn poseidon2_addRc(roundIndex:u32) {
  for (var i = 0u; i<12u; i++) {
    input[i] = add(input[i], RC12[roundIndex][i]);
  }
}
fn poseidon2_sbox() {
  for (var i = 0u; i<12u; i++) {
    input[i] = pow7(input[i]);
  }
}
fn sumInputs() -> GoldilocksField {
  let p0 = add(add(input[0], input[1]), add(input[2], input[3]));
  let p1 = add(add(input[4], input[5]), add(input[6], input[7]));
  let p2 = add(add(input[8], input[9]), add(input[10], input[11]));
  return add3(p0, p1, p2);
}
fn poseidon2_matmulInternal() {
  let sum = sumInputs();
  for (var i = 0u; i<12u; i++) {
    input[i] = add(sum, mul(MAT_DIAG12_M_1[i], input[i]));
  }
}
fn poseidon2_permute() {
  poseidon2_matmulExternal();
  /*
  // slightly faster without this loop, cannot unroll the others due to lack of registers
  for (var r = 0u; r<4u; r++) {
    poseidon2_addRc(r);
    poseidon2_sbox();
    poseidon2_matmulExternal();
  }*/
  
  poseidon2_addRc(0u);
  poseidon2_sbox();
  poseidon2_matmulExternal();
  poseidon2_addRc(1u);
  poseidon2_sbox();
  poseidon2_matmulExternal();
  poseidon2_addRc(2u);
  poseidon2_sbox();
  poseidon2_matmulExternal();
  poseidon2_addRc(3u);
  poseidon2_sbox();
  poseidon2_matmulExternal();


  for (var r = 4u; r<26u; r++) {
    input[0] = pow7(add(input[0], RC12[r][0]));
    poseidon2_matmulInternal();
  }
  
  for (var r = 26u; r<30u; r++) {
    poseidon2_addRc(r);
    poseidon2_sbox();
    poseidon2_matmulExternal();
  }
}
fn copyToInput(s: PoseidonState) {
  input[0] = s[0];
  input[1] = s[1];
  input[2] = s[2];
  input[3] = s[3];
  input[4] = s[4];
  input[5] = s[5];
  input[6] = s[6];
  input[7] = s[7];
  input[8] = s[8];
  input[9] = s[9];
  input[10] = s[10];
  input[11] = s[11];

}

fn copyToInputFromArrayTwoToOne(a: PoseidonHashOut, b: PoseidonHashOut) {
  input[0] = a[0];
  input[1] = a[1];
  input[2] = a[2];
  input[3] = a[3];
  input[4] = b[0];
  input[5] = b[1];
  input[6] = b[2];
  input[7] = b[3];
  input[8] = ZERO;
  input[9] = ZERO;
  input[10] = ZERO;
  input[11] = ZERO;

}
fn getFinalizedHashOut() -> PoseidonHashOut {
  return PoseidonHashOut(input[0], input[1], input[2], input[3]);
}
@group(0) @binding(0) var<storage, read_write>data0: array<PoseidonHashOut>;
@group(0) @binding(1) var<storage, read_write>data1: array<PoseidonHashOut>;
@group(1) @binding(0) var <uniform>ticktock: u32;

@compute @workgroup_size(1) fn computeParentMerkleHash(
  @builtin(global_invocation_id) id: vec3 <u32 >
) {
  let i = id.x+id.y*32768u; // parent node index
  let base = i * 2u;
  if (ticktock == 0u) {
    copyToInputFromArrayTwoToOne(data0[base], data0[base + 1]);
  } else {
    copyToInputFromArrayTwoToOne(data1[base], data1[base + 1]);
  }
  poseidon2_permute();
  if (ticktock == 0u) {
    data1[i] = getFinalizedHashOut();
  } else {
    data0[i] = getFinalizedHashOut();
  }
}