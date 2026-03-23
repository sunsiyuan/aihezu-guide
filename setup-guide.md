# aihezu 配置与使用指南

先完成[风险判断和执行前 Checklist](./risk-assessment.md) 再继续。

## 备份

```bash
cp -R ~/.claude ~/.claude.backup-$(date +%Y%m%d-%H%M%S)
sudo cp /etc/hosts /etc/hosts.backup-$(date +%Y%m%d-%H%M%S)
```

确认备份成功：

```bash
ls -ld ~/.claude.backup-* /etc/hosts.backup-* 2>/dev/null
```

## 安装与配置

### 推荐：只改 base_url

```bash
npx aihezu@2.8.8 config claude
```

执行后确认 `~/.claude/settings.json` 已写入正确的 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_AUTH_TOKEN`。

根据[实测记录](./test-records/2025-03-initial.md)，只做这一步，主请求就已经直接发往第三方地址，当前没有证据表明必须先改 hosts。

### 仅在确实需要时：改 hosts

```bash
sudo npx aihezu@2.8.8 install claude
```

这会额外清理 Claude 本地历史并修改系统 hosts，**影响范围更大**。

### 不要执行以下命令

```bash
npx aihezu install
sudo npx aihezu install
npx aihezu install codex
npx aihezu install gemini
sudo npx aihezu install codex
sudo npx aihezu install gemini
```

## 运行后验证

- 检查 `~/.claude/settings.json` 中的 `ANTHROPIC_BASE_URL` 是否符合预期
- 检查 `/etc/hosts` 是否只新增了预期条目（如果执行了 `install`）
- 确认 `~/.codex/` 和 `~/.gemini/` 的配置未被改动
- 在正式使用前，先用一个低敏感项目验证行为

## 模型切换与验证

### 验证当前状态

启动后先看状态：

```text
/status
```

### 切换模型

在 Claude Code 里：

```text
/model sonnet
/model opus
```

启动时指定：

```bash
claude --model sonnet
claude --model opus
```

一次性临时指定：

```bash
ANTHROPIC_MODEL=sonnet claude
```

### 验证切换是否生效

1. `/model opus`（或 `sonnet`）
2. 再执行 `/status`
3. 发一个低敏感测试请求，确认正常返回

注意：切换能否成功，最终取决于第三方中转是否支持对应模型。如果 `opus` 切不过去，不一定是 Claude Code 本身的问题。

### 关于"问模型自己是谁"

模型自报的名称只能作参考，不能作为证明——第三方中转理论上可以把其他模型包装成 Claude 风格接口。`/status` 比 prompt 更可靠，但也只能说明客户端配置声称在请求对应模型。最终可信度取决于你对这个中转的信任程度。

## VS Code 集成

### 推荐方式：使用启动脚本

```bash
./start-vscode-claude-proxy.sh /path/to/project
```

脚本从 `~/.claude/settings.json` 读取 `ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN` 和可选的 `model`，只注入到这一次 VS Code 进程，不污染全局 shell。

### 操作顺序

1. 安装 VS Code 的 Claude Code 扩展
2. 保持 `~/.claude/settings.json` 配置不变，直接在 VS Code 里执行 `Claude: Start Chat`
3. 如果扩展能读到配置，停在这里
4. 如果读不到，使用启动脚本

### 不推荐：写进 ~/.zshrc

```bash
# 不要这样做
echo 'export ANTHROPIC_BASE_URL="..."' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="..."' >> ~/.zshrc
```

原因：全局生效，key 长期明文留在 shell 配置里，之后其他工具也可能误用这个第三方链路。

### 为什么不用 launch.json

`launch.json` 是给调试目标进程用的，不是"启动 VS Code 自己"的配置。Claude 扩展能否读到变量，取决于 VS Code 应用进程启动时继承的环境，而不是 `launch.json`。

## 使用中的注意事项

把通过该中转使用的 Claude 视为非官方、非私密链路：

- 不要粘贴 API key、Cookie、JWT、数据库密码、云账号密钥、SSH 私钥
- 不要让 Claude 读取包含敏感配置的文件（`.env`、`kubeconfig` 等）
- 不要在带客户数据、内部代码、生产日志的目录中使用
- 如果误发了敏感信息，立即轮换相关凭证

## 回滚

```bash
# 恢复 Claude 配置
cp -R ~/.claude.backup-<时间戳> ~/.claude

# 恢复 hosts（如果改过）
sudo cp /etc/hosts.backup-<时间戳> /etc/hosts
```

恢复后，确认 Claude 是否能正常走官方直连。
