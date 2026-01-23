# P1功能 - 快速使用指南

本指南帮助你快速应用已完成的P1功能。

---

## 🎯 1. Toast通知使用指南

### 基础使用

```typescript
import { toast } from "@/hooks/use-toast";

// 成功提示
toast({
  variant: "success",
  title: "操作成功",
  description: "数据已保存"
});

// 错误提示
toast({
  variant: "error",
  title: "操作失败",
  description: "网络连接失败，请重试"
});

// 警告提示
toast({
  variant: "warning",
  title: "注意",
  description: "此操作可能需要较长时间"
});

// 默认提示
toast({
  title: "提示",
  description: "这是一条普通消息"
});
```

### 替换所有alert

```typescript
// ❌ 旧代码
try {
  await api.create(data);
  alert("创建成功");
} catch (error) {
  alert(`失败: ${error}`);
}

// ✅ 新代码
try {
  await api.create(data);
  toast({
    variant: "success",
    title: "✅ 创建成功",
    description: `${data.name} 已保存`
  });
} catch (error) {
  toast({
    variant: "error",
    title: "❌ 创建失败",
    description: error.message
  });
}
```

---

## 📝 2. 表单验证集成指南

### Step 1: 导入必要的依赖

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { dbConnectionSchema, type DbConnectionFormData } from "@/lib/schemas";
```

### Step 2: 创建表单实例

```typescript
const form = useForm<DbConnectionFormData>({
  resolver: zodResolver(dbConnectionSchema),
  defaultValues: {
    name: "",
    type: "mysql",
    host: "localhost",
    port: 3306,
    username: "",
    password: "",
    database_name: ""
  }
});
```

### Step 3: 在JSX中使用

```tsx
<form onSubmit={form.handleSubmit(onSubmit)}>
  {/* 文本输入 */}
  <Input {...form.register("name")} />
  {form.formState.errors.name && (
    <p className="text-sm text-red-500">
      {form.formState.errors.name.message}
    </p>
  )}

  {/* 数字输入 */}
  <Input 
    type="number" 
    {...form.register("port", { valueAsNumber: true })} 
  />
  
  {/* 下拉选择 */}
  <Select
    onValueChange={(value) => form.setValue("type", value)}
    defaultValue={form.getValues("type")}
  >
    <SelectItem value="mysql">MySQL</SelectItem>
  </Select>

  <Button type="submit">提交</Button>
</form>
```

### Step 4: 处理提交

```typescript
const onSubmit = async (data: DbConnectionFormData) => {
  // data 已经通过验证，类型安全
  try {
    await dbConnectionApi.create(data);
    toast({ variant: "success", title: "成功" });
    form.reset(); // 重置表单
  } catch (error) {
    toast({ variant: "error", title: "失败", description: error.message });
  }
};
```

### 手动触发验证

```typescript
// 验证整个表单
const isValid = await form.trigger();

// 验证单个字段
const isPortValid = await form.trigger("port");

// 获取表单值
const values = form.getValues();

// 设置字段值
form.setValue("port", 3306);

// 重置表单
form.reset();
```

---

## 🛡️ 3. 路由保护（自动生效）

中间件已自动保护路由，无需额外配置。

### 保护规则

1. **未登录用户访问 `/chat` 或 `/settings`**
   - 自动重定向到 `/login?redirect=/chat`
   - 登录后自动跳回原页面

2. **已登录用户访问 `/login` 或 `/register`**
   - 自动重定向到 `/chat`

3. **访问根路径 `/`**
   - 未登录 → `/login`
   - 已登录 → `/chat`

### 测试方法

```javascript
// 在浏览器控制台
// 1. 清除Token
localStorage.removeItem('jwt_token');

// 2. 访问受保护页面
window.location.href = '/chat';
// 应该自动跳转到 /login?redirect=/chat

// 3. 登录后
localStorage.setItem('jwt_token', 'your-token');
window.location.href = '/login';
// 应该自动跳转到 /chat
```

---

## 📋 4. 可用的验证Schema

所有Schema都已导出类型，可直接使用：

```typescript
import {
  // Schema
  dbConnectionSchema,
  llmConfigSchema,
  registerSchema,
  loginSchema,
  sessionSchema,
  
  // TypeScript类型
  type DbConnectionFormData,
  type LlmConfigFormData,
  type RegisterFormData,
  type LoginFormData,
  type SessionFormData
} from "@/lib/schemas";
```

---

## 🎨 5. 完整示例：Settings页面集成

参考文件：`app/settings/page-with-validation-example.tsx`

该文件展示了：
- ✅ 表单验证集成
- ✅ Toast通知使用
- ✅ 类型安全的表单处理
- ✅ 测试连接功能
- ✅ 错误处理

### 使用方法

1. 复制示例文件内容
2. 替换当前的 `app/settings/page.tsx`
3. 根据需要调整UI
4. 测试功能

---

## 🔧 常见问题

### Q1: Toast不显示？
**A**: 检查 `app/layout.tsx` 是否包含 `<Toaster />`

### Q2: 表单验证不工作？
**A**: 检查是否正确导入zodResolver和schema

### Q3: 中间件不生效？
**A**: 确保 `middleware.ts` 在 `frontend/` 根目录

### Q4: TypeScript类型错误？
**A**: 使用导出的类型，例如 `DbConnectionFormData`

---

## 📦 需要的依赖（已安装）

```json
{
  "react-hook-form": "^7.52.1",
  "zod": "^3.23.8",
  "@hookform/resolvers": "^3.6.0",
  "@radix-ui/react-toast": "^1.1.5"
}
```

---

## 🚀 下一步建议

1. ✅ 在Settings页面集成表单验证
2. ✅ 替换所有alert为toast
3. ✅ 测试路由保护
4. ✅ 在Login/Register页面使用验证Schema

完整示例代码请参考：
- `frontend/app/settings/page-with-validation-example.tsx`

---

**最后更新**: 2026-01-22  
**维护者**: 开发团队
