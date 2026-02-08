import ReactECharts from 'echarts-for-react';

export function ChartRenderer({ option }: { option: any }) {
  if (!option) return null;
  return (
    <div className="w-full h-64 mt-4 border border-border rounded-lg p-2 bg-card text-card-foreground" role="img" aria-label="Data visualization chart">
      <ReactECharts option={option} style={{ height: '100%', width: '100%' }} />
    </div>
  );
}
