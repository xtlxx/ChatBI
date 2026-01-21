'use client'

import * as React from "react"
import { useToast } from "@/hooks/use-toast"
import { CheckCircle, XCircle, AlertCircle, X } from "lucide-react"

export function Toaster() {
    const { toasts, dismiss } = useToast()

    return (
        <div className="fixed top-0 right-0 z-[100] flex max-h-screen w-full flex-col-reverse p-4 sm:top-auto sm:right-0 sm:bottom-0 sm:flex-col md:max-w-[420px] pointer-events-none">
            {toasts.map(({ id, title, description, variant = "default" }) => {
                const icons = {
                    default: null,
                    success: <CheckCircle className="h-5 w-5 text-green-500" />,
                    error: <XCircle className="h-5 w-5 text-red-500" />,
                    warning: <AlertCircle className="h-5 w-5 text-yellow-500" />,
                }

                const bgColors = {
                    default: "bg-white dark:bg-gray-800",
                    success: "bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800",
                    error: "bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800",
                    warning: "bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800",
                }

                return (
                    <div
                        key={id}
                        className={`pointer-events-auto relative flex w-full items-start gap-3 overflow-hidden rounded-lg border p-4 pr-8 shadow-lg transition-all ${bgColors[variant]} animate-in slide-in-from-top-5`}
                    >
                        {icons[variant]}
                        <div className="flex-1 space-y-1">
                            {title && (
                                <div className="text-sm font-semibold">{title}</div>
                            )}
                            {description && (
                                <div className="text-sm opacity-90">{description}</div>
                            )}
                        </div>
                        <button
                            onClick={() => dismiss(id)}
                            className="absolute right-2 top-2 rounded-md p-1 opacity-70 hover:opacity-100 transition-opacity"
                        >
                            <X className="h-4 w-4" />
                        </button>
                    </div>
                )
            })}
        </div>
    )
}
