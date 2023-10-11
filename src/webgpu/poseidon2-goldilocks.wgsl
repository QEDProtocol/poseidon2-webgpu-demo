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
const MAT_DIAG12_M_1 = array<GoldilocksField, 12>(GoldilocksField(0x16722af9u, 0xcf6f77acu), GoldilocksField(0x4672aebcu, 0x3fd4c0d7u), GoldilocksField(0x1c3d08a8u, 0x9b72bf1cu), GoldilocksField(0xb71e4ac2u, 0xe4940f84u), GoldilocksField(0x7118bc72u, 0x61b27b07u), GoldilocksField(0xb8e661e2u, 0x2efd8379u), GoldilocksField(0x53df0341u, 0x858edcf3u), GoldilocksField(0xfb5c4516u, 0x2d9c20afu), GoldilocksField(0x695defbu, 0x5120143fu), GoldilocksField(0xe34a5c5bu, 0x62fc898au), GoldilocksField(0x99123ed2u, 0xa3d9560cu), GoldilocksField(0x8e7fc933u, 0x98fd739du));

const RC12 = array<array<GoldilocksField, 12>, 30>(
  array<GoldilocksField, 12>(GoldilocksField(0x5fd284a7u, 0xe034a878u), GoldilocksField(0xa42e1b80u, 0xe2463f1eu), GoldilocksField(0x81ae290au, 0x48742e6u), GoldilocksField(0xe990154cu, 0xe4af50adu), GoldilocksField(0xf4f78f8au, 0x8b13ffaau), GoldilocksField(0xdccd8d63u, 0xe3fbead7u), GoldilocksField(0x5eb92bf8u, 0x631a4770u), GoldilocksField(0x98548659u, 0x88fbbb86u), GoldilocksField(0xb0f349c9u, 0x74cd2003u), GoldilocksField(0x764a3f5du, 0xe16a3df6u), GoldilocksField(0x1a71aaa2u, 0x57ce6397u), GoldilocksField(0xe7823051u, 0xdc1f7fd3u)),
  array<GoldilocksField, 12>(GoldilocksField(0x34c18d7au, 0xbb8423beu), GoldilocksField(0xc1b3d6du, 0xf8bc5a2au), GoldilocksField(0x6f7123e5u, 0xf1a01bbdu), GoldilocksField(0xf5e348bu, 0xed960a08u), GoldilocksField(0x87e2390eu, 0x1b9c0c1eu), GoldilocksField(0x729a613eu, 0x18c83cafu), GoldilocksField(0x37a72c4u, 0x671ab9feu), GoldilocksField(0x7d4c276au, 0x508565f6u), GoldilocksField(0x7a482590u, 0x4d2cd882u), GoldilocksField(0x4dd3500bu, 0xa48e11e8u), GoldilocksField(0x5fc2442bu, 0x825a8c95u), GoldilocksField(0x7cddc68u, 0xf573a6eeu)),
  array<GoldilocksField, 12>(GoldilocksField(0x73a39e0bu, 0x7dd3f19cu), GoldilocksField(0x7a796fa6u, 0xcc0f1353u), GoldilocksField(0xaedac57fu, 0x1d9006bfu), GoldilocksField(0x68b0b7deu, 0x4705f69bu), GoldilocksField(0x18bcc57fu, 0x5b62bfb7u), GoldilocksField(0x70563827u, 0x879d8217u), GoldilocksField(0xf8dff0e3u, 0x3da5ccb7u), GoldilocksField(0x6923fc5bu, 0xb49d6a70u), GoldilocksField(0x883a969du, 0xb6a0babeu), GoldilocksField(0x55401960u, 0x2984f9b0u), GoldilocksField(0x5511d79du, 0xcd3496f0u), GoldilocksField(0x63854fc5u, 0x4791da5du)),
  array<GoldilocksField, 12>(GoldilocksField(0x580a39d4u, 0xdb7344d0u), GoldilocksField(0xd1de120au, 0x5aedc4dau), GoldilocksField(0xb8e1abf0u, 0x5e1bdc1fu), GoldilocksField(0xe46747cu, 0x3904c09au), GoldilocksField(0xab85ddcdu, 0xb54a0e23u), GoldilocksField(0xbccbdb3au, 0xc0c3cf05u), GoldilocksField(0x73baf7e9u, 0xb362076au), GoldilocksField(0x81a5d5bau, 0x212c953du), GoldilocksField(0x65d898bdu, 0x212d4cc9u), GoldilocksField(0xf41509b9u, 0xdd44ddd0u), GoldilocksField(0xa67823c0u, 0x8931329fu), GoldilocksField(0xd2a873beu, 0xc65510f4u)),
  array<GoldilocksField, 12>(GoldilocksField(0xa1e16211u, 0xe3ecbb6bu), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x6792bbb6u, 0x70f5b326u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x634757eu, 0xe7560e69u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xc7eaf66eu, 0xafd0202bu), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x71f220fdu, 0x349f4c58u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x31529e0du, 0x3697eb3eu), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x622d9900u, 0x7735d5b0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xcf997668u, 0x5f5b58b9u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x548af9d9u, 0x645534b6u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x91a426a8u, 0x4232d29du), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xed485d35u, 0xb987278au), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x69bb406eu, 0x6dabeef6u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x8b749d40u, 0x35ee7828u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x14af0fc3u, 0x6dcd560fu), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x7ea6383u, 0x71ed3dc0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0xab7f5b6fu, 0x8b6b51cau), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x181dbfa8u, 0xcf2e8cc4u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x306f825au, 0xa01d3f1cu), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x5d8ddb87u, 0xccee646au), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x7cbaffebu, 0x70df6f27u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x56b8f45cu, 0x64ec0a65u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x4fda6e37u, 0x6f68c966u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u), GoldilocksField(0x0u, 0x0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x516fab6fu, 0x387356e4u), GoldilocksField(0x33903e67u, 0x35310dceu), GoldilocksField(0x1d30f912u, 0x45f3e525u), GoldilocksField(0xca428f45u, 0x7c97f480u), GoldilocksField(0x20b50de2u, 0x74d5874cu), GoldilocksField(0xee3dc67fu, 0xff1d5b7cu), GoldilocksField(0xc0ff3de9u, 0xa04d5d5au), GoldilocksField(0x7d24580eu, 0x1cefb5ebu), GoldilocksField(0xcc0104adu, 0xf685e1bfu), GoldilocksField(0xdb22ead4u, 0x6204dd95u), GoldilocksField(0x7c73c440u, 0x8265c6c5u), GoldilocksField(0xb4e1e382u, 0x4f708ab0u)),
  array<GoldilocksField, 12>(GoldilocksField(0x52fbffa7u, 0xcfc60c7au), GoldilocksField(0xd8910306u, 0x9c0c1951u), GoldilocksField(0xc89819f2u, 0x4d06df27u), GoldilocksField(0x75eca660u, 0x621bdb0eu), GoldilocksField(0x79cee57u, 0x343adffdu), GoldilocksField(0xdebde398u, 0xa760f0e5u), GoldilocksField(0xd97b188au, 0xe3110fefu), GoldilocksField(0x6b150297u, 0xed6584eu), GoldilocksField(0xd0d079c0u, 0x2b10e625u), GoldilocksField(0x2057264fu, 0xefa49344u), GoldilocksField(0x3f26a2b6u, 0xebcfaa7bu), GoldilocksField(0x8e343e2au, 0xf36bcda2u)),
  array<GoldilocksField, 12>(GoldilocksField(0x3b67aa9eu, 0xa1183cb6u), GoldilocksField(0xd5e5b0bau, 0x40f3e415u), GoldilocksField(0x7eff7b15u, 0xc51fc236u), GoldilocksField(0xaebc649fu, 0xe07fe5f3u), GoldilocksField(0x6968e8aau, 0xc9cb2be5u), GoldilocksField(0x69078a0eu, 0x648600dbu), GoldilocksField(0x1256edb9u, 0x4e9135abu), GoldilocksField(0x435556c2u, 0x382c73u), GoldilocksField(0xc9150ddfu, 0x1d78cafau), GoldilocksField(0x6215a233u, 0xb8df60abu), GoldilocksField(0x1f8fcd9au, 0xa7a65ba3u), GoldilocksField(0xd964006bu, 0x907d436du)),
  array<GoldilocksField, 12>(GoldilocksField(0x28633b97u, 0x3bdf7fd5u), GoldilocksField(0x9c0cc0f8u, 0x265adb35u), GoldilocksField(0x34b39614u, 0xf16cfc40u), GoldilocksField(0x8fa0947u, 0x71f0751bu), GoldilocksField(0xb5403a37u, 0x3165eda4u), GoldilocksField(0x80467e46u, 0xca30fc56u), GoldilocksField(0xd37777c5u, 0x4c743354u), GoldilocksField(0x6bba4a09u, 0x3d1f0a4eu), GoldilocksField(0xafa75181u, 0xc0c2e289u), GoldilocksField(0x948978b7u, 0x1e4fa2adu), GoldilocksField(0x7a0bb26au, 0x2a226a12u), GoldilocksField(0x357ce76u, 0xe61738a7u))
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

fn mul(a: GoldilocksField, b: GoldilocksField) -> GoldilocksField {
  return reduce(mul128(a, b));
}

fn add128(a: vec2<u32>, b: vec2<u32>) -> vec4 <u32>{
  let lower = a.x + b.x;
  let carryUpper = select(0u, 1u, lower<a.x);
  let upper = a.y + b.y + carryUpper;
  let top = select(0u, 1u,upper<a.y ||upper<b.y);
  // w is always 0, since the sum of two field elements are at most 0x1fffffffc00000002 (65 bits)
  return vec4 <u32>(lower,upper, top, 0u);
}

fn add(a: GoldilocksField, b: GoldilocksField) -> GoldilocksField {
  return reduce(add128(a, b));
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

  for (var r = 0u; r<4u; r++) {
    poseidon2_addRc(r);
    poseidon2_sbox();
    poseidon2_matmulExternal();
  }

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