import type { Site } from "./types";

export const SITE: Site = {
  website: "https://features.ZZZZZ.tractstack.com/", // replace this with your domain
  author: "At Risk Media",
  desc: "All-in-one publishing platform to grow your content into a business",
  title: "TractStack",
  ogImage: "og.jpg",
};

export const LOCALE = {
  lang: "en",
  langTag: ["en-EN"],
} as const;

export const LOGO_IMAGE = {
  enable: false,
  svg: true,
  width: 216,
  height: 46,
};
