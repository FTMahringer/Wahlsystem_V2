import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Wahlsystem Docs',
  tagline: 'Documentation for the school election platform',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://ftmahringer.github.io',
  baseUrl: '/Wahlsystem_V2/',
  organizationName: 'FTMahringer',
  projectName: 'Wahlsystem_V2',
  deploymentBranch: 'gh-pages',

  onBrokenLinks: 'throw',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/FTMahringer/Wahlsystem_V2/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Wahlsystem Docs',
      logo: {
        alt: 'Wahlsystem logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {to: '/docs/roadmap', label: 'Roadmap', position: 'left'},
        {
          href: 'https://github.com/FTMahringer/Wahlsystem_V2',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Overview',
              to: '/docs/overview',
            },
            {label: 'Admin guide', to: '/docs/admin-guide'},
          ],
        },
        {
          title: 'Project',
          items: [
            {
              label: 'Repository',
              href: 'https://github.com/FTMahringer/Wahlsystem_V2',
            },
            {
              label: 'Frontend app',
              href: 'http://localhost:5173',
            },
            {
              label: 'Backend API',
              href: 'http://localhost:8080/api/v1',
            },
          ],
        },
        {
          title: 'Guides',
          items: [
            {
              label: 'Development',
              to: '/docs/development',
            },
            {
              label: 'Election types',
              to: '/docs/election-types',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Wahlsystem. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
