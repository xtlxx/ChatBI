import os
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict

class CodeCollector:
    """代码收集器，用于扫描和整理项目源代码"""
    
    def __init__(self, project_root=None):
        self.project_root = Path(project_root) if project_root else Path(__file__).parent
        self.file_index = []
        self.error_files = []
        self.duplicate_files = []
        self.processed_files = set()
        
        # 后端代码扩展名
        self.backend_extensions = ['.py', '.sql']
        # 前端代码扩展名
        self.frontend_extensions = ['.ts', '.tsx', '.js', '.jsx', '.css', '.json']
        
        # 需要跳过的目录
        self.skip_dirs = {
            '.git', '.idea', '.vscode', '.minimax', '.trae', 'node_modules',
            '__pycache__', 'coverage', 'test-results', 'dist', 'build', '.venv',
            'venv', 'env', '.pytest_cache', '.mypy_cache', 'htmlcov'
        }
    
    def get_code_files(self, directory, extensions):
        """获取指定目录下所有指定扩展名的代码文件"""
        code_files = []
        directory = Path(directory)
        
        if not directory.exists():
            print(f"警告: 目录不存在 - {directory}")
            return code_files
        
        for root, dirs, files in os.walk(directory):
            # 跳过隐藏目录和特定目录
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in self.skip_dirs]
            
            for file in files:
                if any(file.endswith(ext) for ext in extensions):
                    file_path = Path(root) / file
                    code_files.append(file_path)
        
        return code_files
    
    def read_file_content(self, file_path):
        """读取文件内容，保持原始格式和缩进"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return content, None
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='gbk') as f:
                    content = f.read()
                return content, None
            except Exception as e:
                return None, f"编码错误: {str(e)}"
        except PermissionError:
            return None, f"权限错误: 无法读取文件"
        except IOError as e:
            return None, f"IO错误: {str(e)}"
        except Exception as e:
            return None, f"未知错误: {str(e)}"
    
    def organize_by_directory(self, files):
        """按目录结构组织文件"""
        directory_tree = defaultdict(list)
        
        for file_path in files:
            try:
                rel_path = file_path.relative_to(self.project_root)
                parent_dir = str(rel_path.parent)
                directory_tree[parent_dir].append(file_path)
            except ValueError:
                continue
        
        # 按目录名和文件名排序
        sorted_tree = {}
        for dir_name in sorted(directory_tree.keys()):
            sorted_tree[dir_name] = sorted(directory_tree[dir_name])
        
        return sorted_tree
    
    def generate_file_index(self, section_name):
        """生成文件清单索引"""
        index_lines = []
        index_lines.append("=" * 100)
        index_lines.append(f"{section_name} 文件清单索引 (FILE INDEX)")
        index_lines.append("=" * 100)
        index_lines.append(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        index_lines.append(f"项目根目录: {self.project_root}")
        index_lines.append("")
        
        # 统计信息
        total_files = len(self.file_index)
        total_errors = len(self.error_files)
        total_duplicates = len(self.duplicate_files)
        
        index_lines.append("-" * 100)
        index_lines.append("统计信息 (STATISTICS)")
        index_lines.append("-" * 100)
        index_lines.append(f"成功处理的文件: {total_files} 个")
        index_lines.append(f"读取失败的文件: {total_errors} 个")
        index_lines.append(f"重复的文件: {total_duplicates} 个")
        index_lines.append("")
        
        # 文件索引表
        index_lines.append("-" * 100)
        index_lines.append("文件索引表 (FILE INDEX TABLE)")
        index_lines.append("-" * 100)
        index_lines.append(f"{'序号':<6} {'起始位置':<12} {'文件大小':<12} {'文件类型':<15} {'相对路径'}")
        index_lines.append("-" * 100)
        
        for idx, file_info in enumerate(self.file_index, 1):
            rel_path = file_info['rel_path']
            position = file_info['position']
            size = file_info['size']
            file_type = file_info['type']
            
            # 截断过长的路径
            if len(rel_path) > 50:
                rel_path_display = '...' + rel_path[-47:]
            else:
                rel_path_display = rel_path
            
            index_lines.append(f"{idx:<6} {position:<12} {size:<12} {file_type:<15} {rel_path_display}")
        
        index_lines.append("")
        
        # 错误文件列表
        if self.error_files:
            index_lines.append("-" * 100)
            index_lines.append("读取失败的文件 (ERROR FILES)")
            index_lines.append("-" * 100)
            for error_info in self.error_files:
                rel_path = error_info['rel_path']
                error_msg = error_info['error']
                index_lines.append(f"✗ {rel_path}")
                index_lines.append(f"  错误: {error_msg}")
            index_lines.append("")
        
        # 重复文件列表
        if self.duplicate_files:
            index_lines.append("-" * 100)
            index_lines.append("重复的文件 (DUPLICATE FILES)")
            index_lines.append("-" * 100)
            for dup_info in self.duplicate_files:
                rel_path = dup_info['rel_path']
                index_lines.append(f"⚠ {rel_path} (已跳过)")
            index_lines.append("")
        
        index_lines.append("")
        index_lines.append("=" * 100)
        index_lines.append("文件清单索引结束")
        index_lines.append("=" * 100)
        index_lines.append("")
        index_lines.append("")
        
        return index_lines
    
    def generate_section_file(self, files, section_name, output_filename):
        """生成单个部分的代码文件（后端或前端）"""
        output_path = self.project_root / output_filename
        
        # 重置索引和计数器
        self.file_index = []
        self.error_files = []
        self.duplicate_files = []
        self.processed_files = set()
        
        # 按目录结构组织文件
        organized_files = self.organize_by_directory(files)
        
        # 生成内容
        content_lines = []
        
        # 添加文件头
        content_lines.append("=" * 100)
        content_lines.append(f"{section_name} 源代码汇总 ({section_name} SOURCE CODE SUMMARY)")
        content_lines.append("=" * 100)
        content_lines.append(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        content_lines.append(f"项目根目录: {self.project_root}")
        content_lines.append("")
        
        # 占位符：文件索引起始位置
        index_start_placeholder = len('\n'.join(content_lines)) + 1
        content_lines.append("[文件索引将在最后生成]")
        content_lines.append("")
        content_lines.append("")
        
        # 按目录组织代码内容
        current_position = len('\n'.join(content_lines)) + 1
        
        print(f"  读取 {section_name} 文件内容...")
        processed_count = 0
        error_count = 0
        duplicate_count = 0
        
        for dir_name in sorted(organized_files.keys()):
            files_in_dir = organized_files[dir_name]
            
            content_lines.append("=" * 100)
            content_lines.append(f"目录: {dir_name}")
            content_lines.append(f"文件数量: {len(files_in_dir)}")
            content_lines.append("=" * 100)
            content_lines.append("")
            
            for file_path in files_in_dir:
                rel_path = str(file_path.relative_to(self.project_root))
                
                # 检查是否重复
                file_key = rel_path
                if file_key in self.processed_files:
                    self.duplicate_files.append({
                        'rel_path': rel_path
                    })
                    duplicate_count += 1
                    continue
                
                self.processed_files.add(file_key)
                
                # 读取文件内容
                file_content, error = self.read_file_content(file_path)
                
                if error:
                    self.error_files.append({
                        'rel_path': rel_path,
                        'error': error
                    })
                    error_count += 1
                    continue
                
                # 记录文件索引
                file_size = len(file_content)
                file_type = file_path.suffix
                
                self.file_index.append({
                    'rel_path': rel_path,
                    'position': current_position,
                    'size': f"{file_size:,} bytes",
                    'type': file_type
                })
                
                # 添加文件内容
                content_lines.append("-" * 100)
                content_lines.append(f"文件: {rel_path}")
                content_lines.append(f"大小: {file_size:,} bytes | 类型: {file_type}")
                content_lines.append(f"起始位置: {current_position}")
                content_lines.append("-" * 100)
                content_lines.append("")
                content_lines.append(file_content)
                content_lines.append("")
                content_lines.append("")
                
                # 更新当前位置
                current_position = len('\n'.join(content_lines)) + 1
                processed_count += 1
                
                if processed_count % 100 == 0:
                    print(f"    已处理 {processed_count} 个文件...")
        
        print(f"  处理完成: {processed_count} 个文件成功, {error_count} 个失败, {duplicate_count} 个重复")
        
        # 生成文件索引
        print(f"  生成 {section_name} 文件索引...")
        index_lines = self.generate_file_index(section_name)
        
        # 合并内容
        final_content = []
        final_content.extend(content_lines[:index_start_placeholder])
        final_content.extend(index_lines)
        final_content.extend(content_lines[index_start_placeholder:])
        
        # 写入文件
        print(f"  写入文件: {output_path}")
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(final_content))
            
            # 获取文件大小
            file_size = output_path.stat().st_size
            
            print(f"  ✓ {section_name} 代码文件生成成功！")
            print(f"    输出文件: {output_path}")
            print(f"    文件大小: {file_size:,} bytes ({file_size / 1024 / 1024:.2f} MB)")
            print(f"    成功处理: {processed_count} 个文件")
            print(f"    读取失败: {error_count} 个文件")
            print(f"    重复文件: {duplicate_count} 个文件")
            
            if self.error_files:
                print(f"    ⚠ 警告: 有 {len(self.error_files)} 个文件读取失败")
            
            if self.duplicate_files:
                print(f"    ⚠ 注意: 有 {len(self.duplicate_files)} 个重复文件已被跳过")
            
            return True
            
        except Exception as e:
            print(f"  ✗ 写入文件失败: {str(e)}")
            return False
    
    def generate_code_txt(self):
        """生成代码文件（后端和前端分别导出）"""
        print(f"开始扫描项目代码...")
        print(f"项目根目录: {self.project_root}")
        print("")
        
        # 获取后端代码文件
        print("扫描后端代码...")
        backend_dir = self.project_root / 'backend'
        backend_files = self.get_code_files(str(backend_dir), self.backend_extensions)
        print(f"  找到 {len(backend_files)} 个后端文件")
        print("")
        
        # 获取前端代码文件
        print("扫描前端代码...")
        frontend_dir = self.project_root / 'frontend'
        frontend_files = self.get_code_files(str(frontend_dir), self.frontend_extensions)
        print(f"  找到 {len(frontend_files)} 个前端文件")
        print("")
        
        # 生成后端代码文件
        print("=" * 80)
        print("生成后端代码文件...")
        print("=" * 80)
        backend_success = self.generate_section_file(backend_files, "后端 (Backend)", "backendcode.txt")
        print("")
        
        # 生成前端代码文件
        print("=" * 80)
        print("生成前端代码文件...")
        print("=" * 80)
        frontend_success = self.generate_section_file(frontend_files, "前端 (Frontend)", "frontend.txt")
        print("")
        
        # 总结
        print("=" * 80)
        print("代码文件生成完成！")
        print("=" * 80)
        total_files = len(backend_files) + len(frontend_files)
        print(f"总计文件: {total_files} 个")
        print(f"  - 后端: {len(backend_files)} 个")
        print(f"  - 前端: {len(frontend_files)} 个")
        print("")
        print(f"输出文件:")
        print(f"  - backendcode.txt (后端代码)")
        print(f"  - frontend.txt (前端代码)")
        print("")
        
        if not backend_success or not frontend_success:
            print("⚠ 警告: 部分文件生成失败")
            sys.exit(1)

def main():
    """主函数"""
    try:
        collector = CodeCollector()
        collector.generate_code_txt()
    except KeyboardInterrupt:
        print("\n\n操作已取消。")
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ 发生错误: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
