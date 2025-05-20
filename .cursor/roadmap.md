# Thaki Cloud Tech Blog: Development & Launch Roadmap

This document outlines a phased roadmap for the development, launch, and ongoing management of the Thaki Cloud tech blog. The primary objective is to establish an expert-focused platform for talent acquisition.

## Phase 1: Foundation & Initial Setup (Completed)

*   **Task 1.1: Project Initialization & Understanding**
    *   Objective: Understand the existing Jekyll template and project structure.
    *   Activities:
        *   Review `_config.yml`, directory layout (`_posts`, `_includes`, `_layouts`, `assets`, etc.).
        *   Document initial project structure (`project_structure.md`).
    *   Status: **Completed**
*   **Task 1.2: Branding Transformation (2i to Thaki Cloud)**
    *   Objective: Update all instances of previous branding to Thaki Cloud.
    *   Activities:
        *   Global search for "2i" and derivatives.
        *   Update `_config.yml` with Thaki Cloud site title, author, email, URLs, social links.
        *   Identify and preserve technical terms (e.g., "T2I").
    *   Status: **Completed**
*   **Task 1.3: Content Cleanup**
    *   Objective: Remove irrelevant existing blog posts.
    *   Activities:
        *   Delete all markdown files from `_posts/` and its subdirectories.
    *   Status: **Completed** (with some manual user intervention for specific files)
*   **Task 1.4: Define Core Content Categories for Recruitment**
    *   Objective: Establish specialized, expert-level content categories aligned with Thaki Cloud's focus (Private Cloud IaaS, PaaS, SaaS, LLM Ops) and recruitment goals.
    *   Activities:
        *   Identify initial generic categories and then refine to specialized ones.
        *   Create new subdirectories within `_posts/` for each category (e.g., `_posts/iaas/`, `_posts/paas/`, etc.).
        *   Rename category folders to single, appropriate English words.
    *   Status: **Completed**
*   **Task 1.5: Create Placeholder Content Guides**
    *   Objective: Provide authors with structured guidance for creating content in each category.
    *   Activities:
        *   Develop detailed placeholder markdown files (e.g., `placeholder-iaas-guide.md`) for each category, including topic examples, structure advice, and tone.
    *   Status: **Completed**
*   **Task 1.6: Populate Initial Project Documentation (`.cursor` files)**
    *   Objective: Document project context, architecture, design guidelines, and requirements.
    *   Activities:
        *   Populate `architecture.md`, `context.md`, `design.md`, `requirements.md`.
    *   Status: **In Progress (Roadmap.md being created now)**

## Phase 2: Design Customization & Content Population (Current Focus)

*   **Task 2.1: Implement Thaki Cloud Visual Branding**
    *   Objective: Fully integrate Thaki Cloud's visual identity into the blog.
    *   Activities:
        *   Design/obtain and integrate Thaki Cloud logo (masthead, favicon, social previews).
        *   Define and apply Thaki Cloud color palette across the site (CSS/SASS updates).
        *   Select and implement official Thaki Cloud typography.
        *   Update `_includes/author-profile.html` with Thaki Cloud company information.
        *   Customize `_data/navigation.yml` for main site navigation.
    *   Key Files: `_config.yml`, `assets/css/main.scss`, `_sass/minimal-mistakes/_variables.scss`, `_includes/`, `assets/images/`.
*   **Task 2.2: Develop Initial Batch of Core Content**
    *   Objective: Populate the blog with a foundational set of high-quality articles across the defined categories.
    *   Activities:
        *   Prioritize 1-2 flagship posts for each key category (IaaS, PaaS, SaaS, LLM Ops, Careers).
        *   Ensure content is expert-level, engaging, and aligned with recruitment goals.
        *   Incorporate relevant keywords for SEO.
*   **Task 2.3: Refine Layouts & User Experience (UX)**
    *   Objective: Optimize the blog for readability, navigation, and engagement.
    *   Activities:
        *   Review and adjust homepage layout to feature key content and CTAs.
        *   Ensure post layouts are clean, with excellent code block rendering and image display.
        *   Optimize category/tag pages for discoverability.
        *   Test responsiveness across major devices and browsers.
*   **Task 2.4: Implement Recruitment CTAs**
    *   Objective: Clearly guide interested readers towards career opportunities.
    *   Activities:
        *   Strategically place CTAs (e.g., "Explore Careers at Thaki Cloud," "View Open Roles") in sidebars, footers, and relevant posts.
        *   Ensure CTAs link directly to the Thaki Cloud careers page.

## Phase 3: Launch & Initial Promotion

*   **Task 3.1: Pre-Launch Checklist & Testing**
    *   Objective: Ensure the blog is ready for public launch.
    *   Activities:
        *   Thoroughly proofread all initial content.
        *   Test all links and navigation.
        *   Validate SEO settings (titles, descriptions, sitemap, robots.txt).
        *   Perform cross-browser and cross-device testing.
        *   Verify Google Analytics (or other analytics) integration.
*   **Task 3.2: Deploy to Production Environment**
    *   Objective: Make the blog live.
    *   Activities:
        *   Configure hosting environment (e.g., GitHub Pages custom domain, Netlify, Vercel).
        *   Build and deploy the final site.
*   **Task 3.3: Initial Promotion & Announcement**
    *   Objective: Drive initial traffic and awareness.
    *   Activities:
        *   Announce the blog launch on Thaki Cloud's existing channels (website, social media, internal comms).
        *   Share key articles on relevant professional networks (e.g., LinkedIn).

## Phase 4: Ongoing Content Creation & Evolution

*   **Task 4.1: Establish Content Calendar & Cadence**
    *   Objective: Maintain a regular flow of new, high-quality content.
    *   Activities:
        *   Develop a content calendar with planned topics and publication dates.
        *   Assign authorship and deadlines.
        *   Aim for a consistent publishing schedule (e.g., 1-2 posts per week/fortnight).
*   **Task 4.2: Monitor Analytics & Gather Feedback**
    *   Objective: Understand content performance and user engagement to refine strategy.
    *   Activities:
        *   Regularly review web analytics (page views, bounce rate, time on page, popular posts).
        *   Monitor social shares and comments.
        *   Gather feedback from readers and internal stakeholders.
*   **Task 4.3: SEO Optimization & Keyword Monitoring**
    *   Objective: Continuously improve search engine visibility.
    *   Activities:
        *   Monitor keyword rankings for target terms.
        *   Identify new content opportunities based on search trends.
        *   Optimize existing content based on performance data.
*   **Task 4.4: Promote Content Regularly**
    *   Objective: Maximize reach and engagement of published content.
    *   Activities:
        *   Share new posts across all relevant channels.
        *   Reshare older, evergreen content periodically.
        *   Encourage employees to share posts within their networks.
*   **Task 4.5: Evolve Content Strategy Based on Recruitment Needs**
    *   Objective: Ensure the blog continues to support evolving talent acquisition priorities.
    *   Activities:
        *   Periodically review and update content categories if needed.
        *   Tailor content to highlight skills and expertise sought in current job openings.
        *   Showcase company culture and employee experiences to attract candidates.
*   **Task 4.6: Technical Maintenance**
    *   Objective: Keep the blog platform secure and up-to-date.
    *   Activities:
        *   Regularly update Jekyll, the Minimal Mistakes theme, and any plugins/dependencies.
        *   Monitor for and address any technical issues.

This roadmap provides a structured approach to launching and managing the Thaki Cloud tech blog. Flexibility will be important to adapt to new insights and changing business needs.
