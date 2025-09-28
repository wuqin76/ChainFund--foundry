# FundMe 智能合约项目

这是一个基于 Foundry 开发的去中心化众筹智能合约项目。该合约允许用户捐赠 ETH，并使用 Chainlink 价格预言机确保最低捐赠金额达到 5 美元等值。

## 📋 项目简介

### 主要功能

- 💰 接受 ETH 捐赠（最低 5 美元等值）
- 📊 使用 Chainlink 价格预言机获取实时 ETH/USD 汇率
- 👑 只有合约所有者可以提取资金
- 📝 记录所有捐赠者信息

### 技术栈

- **Solidity ^0.8.18**: 智能合约开发语言
- **Foundry**: 以太坊开发工具链
- **Chainlink**: 去中心化价格预言机

## 📁 项目结构详解

```
foundry-fund-me/
├── 📋 foundry.toml          # Foundry 配置文件
├── 🔒 foundry.lock          # 依赖版本锁定文件
├── 📖 README.md             # 项目说明文档
├── 🚫 .gitignore           # Git 忽略文件配置
├── 🔗 .gitmodules          # Git 子模块配置
├── 📁 src/                  # 智能合约源代码
│   ├── 💰 FundMe.sol        # 主众筹合约
│   └── 🔄 PriceConverter.sol # 价格转换库
├── 📁 test/                 # 测试文件目录
├── 📁 script/               # 部署脚本目录
├── 📁 lib/                  # 外部依赖库
│   ├── forge-std/           # Foundry 标准测试库
│   └── chainlink-brownie-contracts/ # Chainlink 合约库
├── 📁 out/                  # 编译输出目录
├── 📁 cache/                # 编译缓存目录
└── 📁 .github/workflows/    # GitHub Actions CI/CD
    └── test.yml
```

### 📄 核心文件说明

#### 🔧 配置文件

- **`foundry.toml`**: Foundry 主配置文件
  - 定义源代码、输出、依赖路径
  - 配置 Chainlink 合约路径映射
- **`foundry.lock`**: 依赖版本锁定
  - 确保团队使用相同版本的依赖库
- **`.gitignore`**: Git 版本控制忽略规则
  - 忽略编译输出、缓存、环境变量等文件

#### 💻 智能合约

- **`src/FundMe.sol`**: 主众筹合约

  ```solidity
  主要功能：
  - fund(): 接受 ETH 捐赠
  - withdraw(): 提取资金（仅所有者）
  - getVersion(): 获取价格预言机版本
  ```

- **`src/PriceConverter.sol`**: 价格转换库
  ```solidity
  主要功能：
  - getPrice(): 获取 ETH/USD 价格
  - getConversionRate(): 转换 ETH 为 USD 价值
  ```

#### 📦 依赖管理

- **`lib/forge-std/`**: Foundry 标准库
  - 提供测试框架和工具函数
- **`lib/chainlink-brownie-contracts/`**: Chainlink 合约库
  - 提供价格预言机接口

## 🚀 快速开始

### 环境准备

确保已安装 Foundry:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 编译合约

```bash
forge build
```

### 运行测试

```bash
forge test
```

### 代码格式化

```bash
forge fmt
```

### Gas 使用量快照

```bash
forge snapshot
```

## 🔧 开发工具

### Foundry 工具链

- **Forge**: 测试框架（类似 Truffle, Hardhat）
- **Cast**: 与智能合约交互的命令行工具
- **Anvil**: 本地以太坊节点（类似 Ganache）
- **Chisel**: Solidity REPL 交互式环境

### 本地开发网络

启动本地节点：

```bash
anvil
```

### 部署合约

```bash
forge script script/DeployFundMe.s.sol:DeployFundMeScript --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

### 合约交互

```bash
# 查询合约信息
cast call <CONTRACT_ADDRESS> "MINIMUM_USD()" --rpc-url <RPC_URL>

# 发送交易
cast send <CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
```

## 📚 学习资源

- [Foundry 官方文档](https://book.getfoundry.sh/)
- [Chainlink 文档](https://docs.chain.link/)
- [Solidity 官方文档](https://docs.soliditylang.org/)

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

## 📄 许可证

MIT License

---

> 💡 **新手提示**: 这是一个学习项目，适合初学者了解智能合约开发、价格预言机使用和 Foundry 工具链。建议先在测试网络上进行实验！

## 外部导入需要的网址

1. 安装依赖.forge install smartcontractkit/chainlink-brownie-contracts@1.1.1
2. 配置映射 remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]
3. 代码中使用 import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

## 保存环境变量

source .env

.env 文件只是用来保存环境变量（比如你的 URL、API KEY 等），但不会自动让系统读取和应用这些变量。当前终端会话才会加载和“记住”这些变量，这样你在后续运行的命令或脚本（比如 forge test、npm run 等）才能获取这些变量的值


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