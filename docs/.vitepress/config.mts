import { type DefaultTheme, defineConfig, type UserConfig } from "vitepress";
import { withSidebar } from "vitepress-sidebar";
import type { VitePressSidebarOptions } from "vitepress-sidebar/types";

const config: UserConfig<DefaultTheme.Config> = {
  title: "低レベルコンテナランタイム自作講座",
  head: [
    ["link", { rel: "icon", href: "/favicon.webp" }],
    ["meta", { property: "og:image", content: "/image.png" }],
    [
      "meta",
      {
        property: "og:site_name",
        content: "低レベルコンテナランタイム自作講座",
      },
    ],
    [
      "meta",
      {
        property: "og:description",
        content: "Go Workshop Conference 2025 IN KOBEにて開催",
      },
    ],
  ],
  srcDir: ".",
  themeConfig: {
    nav: [{ text: "Home", link: "/" }],
    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/logica0419/coding-kubernetes",
      },
    ],
  },
};

const sidebarConfigs: VitePressSidebarOptions = {
  documentRootPath: "/",
  collapsed: false,
  useTitleFromFileHeading: true,
  useFolderTitleFromIndexFile: true,
};

export default defineConfig(withSidebar(config, sidebarConfigs));
