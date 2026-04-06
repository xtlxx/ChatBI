import * as Icons from 'lucide-react';
import React from 'react';

export type IconName = keyof typeof Icons;

export interface IconProps extends Omit<Icons.LucideProps, 'size'> {
  name: IconName;
  size?: 16 | 18 | 20 | 24 | 32; // 约束尺寸梯度
}

export const Icon = ({ name, size = 20, strokeWidth = 1.5, ...props }: IconProps) => {
  const LucideIcon = Icons[name] as React.FC<Icons.LucideProps>;
  if (!LucideIcon) return null;
  return <LucideIcon size={size} strokeWidth={strokeWidth} {...props} />;
};
