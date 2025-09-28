# FundMe (Foundry + Chainlink)

一个使用 Foundry 构建的最小众筹 / 捐款合约示例，集成 Chainlink ETH/USD 预言机（主网/测试网）并在本地 (Anvil) 使用 MockV3Aggregator。

## 功能概览
- 按美元价值限制最小捐款（使用 Chainlink 价格预言机换算 ETH→USD）
- 记录每个地址的累计捐款金额
- 记录捐款者列表
- 仅合约拥有者可提现所有资金
- 支持 `fund()` / `receive()` / `fallback()` 三种方式接收 ETH
- 多网络配置（Sepolia / Mainnet / 本地 Anvil）
- 脚本化部署与交互（捐款、提现）
- 集成测试 + 单元测试
- 部署后自动验证（Etherscan）

## 目录结构
```
.
├── src/
│   ├── FundMe.sol              # 主合约
│   └── PriceConverter.sol      # 金额换算库 (使用 AggregatorV3Interface)
├── script/
│   ├── DeployFundMe.s.sol      # 部署脚本
│   ├── HelperConfig.s.sol      # 不同网络预言机地址 / 本地 Mock 部署
│   └── Interactions.s.sol      # fund / withdraw 交互脚本
├── test/
│   ├── unit/                   # 单元测试（FundMeTest）
│   ├── intergration/           # 集成测试（脚本交互）
│   └── mocks/MockV3Aggregator.sol
├── broadcast/                  # forge script 广播记录
├── foundry.toml                # Foundry 配置 (solc 版本等)
├── Makefile                    # 构建 / 部署命令封装
└── .env                        # 环境变量（RPC / 私钥 / API Key）
```

## 核心合约 (FundMe.sol)
- `MINIMUM_USD`：最小捐款（常量）
- `i_owner`：immutable 合约部署者
- `s_addressToAmountFunded`：地址→累计金额
- `s_funders`：捐款者数组
- `fund()`：验证金额（基于预言机），记录映射与数组
- `withdraw()`：仅拥有者；清空映射与数组后转账（使用 call）
- `receive()/fallback()`：都委托 `fund()`
- `getAddressToAmountFunded()`：外部只读查询（可替代自动 getter，语义更明确）

## 多网络配置 (HelperConfig.s.sol)
- 结构体 `NetworkConfig { address priceFeed; }`
- 构造函数根据 `block.chainid` 选择：
  - Mainnet：真实 Chainlink ETH/USD
  - Sepolia：测试网 Chainlink ETH/USD
  - 其他（本地）：部署 MockV3Aggregator (DECIMALS=18, INITIAL_ANSWER=2000e18)
- `getAnvilEthConfig()`：懒加载 + 缓存，避免重复部署

## 脚本 (forge script)
| 脚本 | 作用 |
|------|------|
| DeployFundMe.s.sol | 部署 FundMe（自动选择预言机地址） |
| Interactions.s.sol: FundFundMe | 调用 fund() 并发送固定 ETH |
| Interactions.s.sol: WithdrawFundMe | 调用 withdraw()（需 owner） |

广播区块链操作：`vm.startBroadcast()` / `vm.stopBroadcast()`  
本地 Mock / 真实链统一接口：`HelperConfig`

## 测试
- 使用 `forge-std/Test.sol` + cheatcodes（`vm.prank`, `vm.deal`, `vm.expectRevert`）
- 单元测试：验证 fund / withdraw 行为与权限
- 集成测试：脚本调用（Interactions）
- 示例命令：
  ```bash
  forge test -vv
  forge test --match-test testOnlyOwnerCanWithdraw
  forge test --fork-url $SEPOLIA_RPC_URL
  ```

## 部署与验证
Makefile 已封装：
```bash
make build
make deploy-sepolia
```
等价：
```bash
forge script script/DeployFundMe.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

## 环境变量 (.env)
```
SEPOLIA_RPC_URL=...
MAINNET_RPC_URL=...
PRIVATE_KEY=...
ETHERSCAN_API_KEY=...
```
建议：生产环境不要直接明文私钥；不要提交 .env。

## 常见问题
| 问题 | 原因 | 解决 |
|------|------|------|
| priceFeed 为 0 地址 | 本地未触发 Mock 部署 | 确保使用 HelperConfig 并调用 getAnvilEthConfig |
| call to non-contract address | 传入 0 地址交互 | 检查部署返回值 & setUp 命名 |
| 需重复 source .env | 新终端未加载变量 | 使用 direnv 或写入 ~/.bashrc |
| 验证失败 | 编译参数不一致 | 确保 foundry.toml solc 版本稳定 |

## 安全注意
- 使用 `call` 转账，需检查返回值
- 清空映射 & 数组顺序：先重置，再转出资金可减小重入面
- 预言机依赖：链上报价滞后性
- 不要在仓库提交真实私钥

## 可改进方向
- 事件 (Funded, Withdrawn)
- 去重 funders（避免数组膨胀）
- 使用自定义错误替换 require 字符串
- Gas 优化（内存缓存 length / 映射批量清理）
- 加入多签提现
- 最小代理（ERC1967 / Clones）支持升级

## 快速演示
```bash
forge build
forge script script/DeployFundMe.s.sol --fork-url anvil
forge test
forge script script/Interactions.s.sol:FundFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## 参考
- Foundry Book: https://book.getfoundry.sh
- Chainlink Docs: https://docs.chain.link
- forge-std Cheatcodes: https://book.getfoundry.sh/cheatcodes

---
本 README 基于代码内注释与当前仓库结构自动总结，供学习与演示使用。




## 优化gas消耗
尽量使用内存读取，少使用存储读取
    function withdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;   //102399
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //执行转账操作
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;  //102510
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //执行转账操作
        require(callSuccess, "Call failed");
    }
FundMeTest:testOnlyOwnerCanWithdraw() (gas: 102510)
FundMeTest:testOnlyOwnerCanWithdrawCheaper() (gas: 102399)

## 查看gas消耗
forge snapshot
生成快照文件，内部有gas消耗


## 完成度

集成测试intergration tests





## 小命令
forge build 的主要作用
1. 编译 Solidity 合约
将 src/ 目录下的 .sol 文件编译成字节码（bytecode）
生成 ABI（Application Binary Interface）
检查语法错误和类型错误
2. 依赖解析
自动解析和处理 import 语句
处理外部库依赖（如 lib/ 目录下的库）
解析 remapping 路径（在 foundry.toml 中配置的路径映射）
3. 生成编译产物
编译成功后，在 out 目录下生成：
4. 代码检查
语法检查（syntax checking）
类型检查（type checking）
代码风格检查（linting）- 如您刚才看到的警告


外部导入需要的网址
1. 安装依赖.forge install smartcontractkit/chainlink-brownie-contracts@1.1.
2. 配置映射 remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]
3. 代码中使用 import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";



查看gas消耗：forge snapshot（生成快照文件，内部有gas消耗）


保存环境变量：source .env