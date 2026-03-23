import { Loader2 } from "lucide-react";

export const Loading = () => (
  <div className="flex items-center justify-center h-screen bg-gray-50">
    <Loader2 className="animate-spin text-blue-500" size={32} />
  </div>
);
