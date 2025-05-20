# 🔧 System Design Overview

(이곳에 시스템 및 모듈 설계를 작성하세요.)

# Design Principles & Guidelines: Thaki Cloud Recruitment Blog

This document outlines the design considerations for the Thaki Cloud recruitment blog, leveraging the "Minimal Mistakes" Jekyll theme and specific customizations to align with Thaki Cloud's branding and recruitment objectives.

## Core Design Philosophy:

*   **Professional & Modern:** The design should project Thaki Cloud as a cutting-edge technology company.
*   **Expert-Focused:** Aesthetics and usability must appeal to experienced tech professionals.
*   **Readability & Accessibility:** Content is king. The design must prioritize clear typography, ample white space, and adherence to web accessibility standards (WCAG).
*   **Brand Consistency:** Reflect Thaki Cloud's visual identity (logo, color palette, typography if defined) consistently across the blog.
*   **Performance:** Fast load times are crucial for user experience and SEO. Static generation helps, but image optimization and efficient code are still important.

## Theme & Customization:

*   **Base Theme:** "Minimal Mistakes" Jekyll theme.
    *   **Rationale:** A popular, well-maintained, feature-rich, and highly customizable theme suitable for technical blogs. It offers responsive design, good typography, and various layout options out-of-the-box.
*   **Branding Implementation:**
    *   **Logo:** Thaki Cloud's logo to be prominently displayed in the site header/navigation. Configured via `_config.yml` and potentially customized in `_includes/masthead.html` or similar.
    *   **Color Palette:** If Thaki Cloud has a defined corporate color palette, these colors should be integrated into the theme by overriding Sass variables in `_sass/minimal-mistakes/_variables.scss` or a custom Sass file.
    *   **Typography:** While Minimal Mistakes has good default fonts, Thaki Cloud's corporate fonts (if any) could be integrated via `@font-face` rules and Sass variable updates.
    *   **Favicon:** `favicon.ico` updated to Thaki Cloud's brand.
*   **Site Title & Tagline:** Updated in `_config.yml` to "Thaki Cloud Tech Blog" (or similar) and a tagline reflecting its recruitment and technology focus.

## Layout & User Experience (UX):

*   **Navigation:**
    *   Clear and intuitive navigation, likely managed via `_data/navigation.yml`.
    *   Should provide easy access to main content categories, an "About" page (if created), and a "Careers" or "Join Us" section.
*   **Homepage (`index.html` / `home` layout):**
    *   Should be engaging, potentially featuring a brief intro to Thaki Cloud, recent/featured posts, and clear calls-to-action for exploring content or careers.
*   **Post Layouts (`_layouts/posts.html`, `_layouts/single.html`):
    *   Emphasis on readability: appropriate line length, font sizes, and contrast.
    *   Author profiles (`author_profile: true` in front matter, `_includes/author-profile.html`) to showcase team members.
    *   Code block styling: Clear and readable syntax highlighting for technical content.
    *   Table of Contents (`toc: true`) for longer articles to improve navigation.
    *   Social sharing buttons.
*   **Category/Tag Pages:** Minimal Mistakes provides archive pages for categories and tags, allowing users to explore related content easily.
*   **Responsive Design:** Ensure the blog is fully responsive and provides an excellent experience across desktop, tablet, and mobile devices (inherent to Minimal Mistakes but good to verify customizations).

## Content Presentation:

*   **Visuals:** Encourage the use of relevant images, diagrams, and architectural drawings in posts to break up text and illustrate complex concepts. These should be stored in `assets/images/posts/` or a similar structured path.
*   **Placeholder Guides:** The design of the placeholder markdown files in each `_posts/` subcategory guides authors on structure and tone, contributing to a consistent reading experience.
*   **Call-to-Action (CTA):** Strategically placed CTAs, especially within or at the end of relevant articles and on the "Careers" page, to direct interested readers to job openings or contact forms.

## Key Files for Design & Branding Customization:

*   `_config.yml`: Site title, logo, author details, theme settings.
*   `_sass/minimal-mistakes/_variables.scss`: Theme SCSS variables (colors, fonts, spacing) for overriding.
*   `_includes/`: Masthead, footer, author profile, UI text snippets.
*   `_layouts/`: Overall page structure.
*   `assets/`: For custom images, CSS, and JavaScript.
*   `_data/navigation.yml`: Site navigation structure.

By adhering to these design principles and effectively customizing the Minimal Mistakes theme, the Thaki Cloud recruitment blog can present a compelling and professional front to potential hires.

### 7. Customization for Thaki Cloud

*   **Logo Integration**: Replace the default Minimal Mistakes or "2i" logo with the official "thakicloud" logo in the masthead, favicon, and social sharing previews.
*   **Color Palette**: Define and apply a color scheme that aligns with thakicloud's branding. This includes primary, secondary, and accent colors for links, buttons, headers, and other UI elements.
*   **Typography**: Select and implement fonts (e.g., from Google Fonts) that reflect thakicloud's professional and modern image. Ensure consistency across headings, body text, and code blocks.
*   **Favicon**: Update the favicon to the thakicloud logo.
*   **Site Title and Tagline**: Ensure these are updated in `_config.yml` and displayed correctly, reflecting "thakicloud Tech Blog" and a relevant tagline focused on innovation and careers.

### 8. Key Files for Design Customization

*   **`_config.yml`**: Site-wide settings including title, description, logo, author details, and theme settings.
*   **`_data/navigation.yml`**: Defines the main navigation links.
*   **`assets/css/main.scss`**: Primary SASS file for custom styles. Import custom SASS partials here.
*   **`_sass/minimal-mistakes/`**: Theme's SASS files. Overriding variables here (e.g., in `_variables.scss`) is a common customization method.
*   **`_includes/`**: HTML snippets for various parts of the site (header, footer, sidebar, author profile). Modifications here can alter layout and content presentation.
    *   `masthead.html`: For logo and navigation customization.
    *   `author-profile.html`: For updating author/company information.
    *   `footer.html`: For copyright and other footer links.
*   **`_layouts/`**: Defines the overall structure of different page types (default, home, post, archive).
*   **`assets/images/`**: Directory for storing images, including logos, favicons, and post-related visuals.

### 9. Future Design Considerations & Enhancements

*   **Interactive Elements**: Explore adding subtle animations or interactive components to showcase technical prowess (e.g., for LLM Ops visualizations, if relevant to a post).
*   **Dark Mode/Light Mode Toggle**: Enhance user experience with a theme toggle.
*   **Custom Post Layouts**: For specific content types like "Thaki Cloud Life & Careers" or "Academic Paper Reviews," consider unique layouts that best present that information.
*   **Call-to-Action (CTA) Optimization**: A/B test different CTA designs and placements for recruitment (e.g., "View Open Positions," "Learn More About Our Culture").
*   **Accessibility Audit**: Ensure the design adheres to WCAG guidelines for accessibility.
*   **Performance Optimization**: Continuously monitor and optimize image sizes, script loading, and other factors affecting page speed.
