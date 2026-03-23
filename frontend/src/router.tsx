import { createBrowserRouter, Navigate } from "react-router-dom";
import { lazy, Suspense } from "react";
import App from "./App";
import { ProtectedRoute } from "./components/layout/ProtectedRoute";
import { Loading } from "./components/ui/Loading";

const Login = lazy(() => import("./pages/auth/Login").then(module => ({ default: module.Login })));
const Register = lazy(() => import("./pages/auth/Register").then(module => ({ default: module.Register })));
const MainPlayground = lazy(() => import("./components/MainPlayground").then(module => ({ default: module.MainPlayground })));

export const router = createBrowserRouter([
  {
    path: "/login",
    element: (
      <Suspense fallback={<Loading />}>
        <Login />
      </Suspense>
    ),
  },
  {
    path: "/register",
    element: (
      <Suspense fallback={<Loading />}>
        <Register />
      </Suspense>
    ),
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        path: "/",
        element: <App />,
        children: [
          {
            index: true,
            element: <Navigate to="/chat/new" replace />,
          },
          {
            path: "chat/:sessionId",
            element: (
              <Suspense fallback={<Loading />}>
                <MainPlayground />
              </Suspense>
            ),
          },
        ],
      },
    ],
  },
  {
    path: "*",
    element: <Navigate to="/" replace />,
  }
]);
