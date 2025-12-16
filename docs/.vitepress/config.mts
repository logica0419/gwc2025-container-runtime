import { type DefaultTheme, defineConfig, type UserConfig } from "vitepress";
import { withSidebar } from "vitepress-sidebar";
import type { VitePressSidebarOptions } from "vitepress-sidebar/types";

const config: UserConfig<DefaultTheme.Config> = {
  title: "低レベルコンテナランタイム自作講座",
  description: "Go Workshop Conference 2025 IN KOBEにて開催",
  head: [
    ["link", { rel: "icon", href: "/favicon.webp" }],
    [
      "meta",
      {
        property: "og:title",
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
    [
      "meta",
      {
        property: "og:url",
        content: "https://gwc2025.logica0419.dev",
      },
    ],
    [
      "meta",
      {
        property: "og:image",
        content: "https://gwc2025.logica0419.dev/image.png",
      },
    ],
  ],
  srcDir: ".",
  lastUpdated: true,
  sitemap: {
    hostname: "https://gwc2025.logica0419.dev",
    lastmodDateOnly: false,
  },
  themeConfig: {
    nav: [{ text: "Home", link: "/" }],
    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/logica0419/gwc2025-container-runtime",
      },
    ],
  },
};

const sidebarConfigs: VitePressSidebarOptions = {
  documentRootPath: "/",
  collapsed: false,
  useTitleFromFileHeading: true,
  useFolderTitleFromIndexFile: true,
  useFolderLinkFromIndexFile: true,
};

export default defineConfig(withSidebar(config, sidebarConfigs));
