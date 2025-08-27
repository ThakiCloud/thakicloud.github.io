# Project Structure

## Root Level

*   `.git/`: Git version control files.
*   `.github/`: GitHub specific files (e.g., workflows, issue templates).
*   `.gitignore`: Specifies intentionally untracked files that Git should ignore.
*   `Gemfile`: A file used by Bundler to manage Ruby gem dependencies.
*   `Gemfile.lock`: Records the exact versions of gems that were installed. This ensures that you use the same gems across different machines.
*   `LICENSE`: Contains the license information for the project.
*   `Rakefile`: A Ruby build program with capabilities similar to Make.
*   `_config.yml`: The main Jekyll configuration file. Contains global configurations and settings for the site.
*   `_data/`: Directory for data files (e.g., YAML, JSON, CSV) that can be used by Jekyll to generate site content.
*   `_includes/`: Directory for HTML snippets that can be included in layouts or other pages. The `author-profile.html` you attached is from here.
*   `_layouts/`: Directory for HTML layout templates.
*   `_pages/`: Directory for custom pages (e.g., About, Contact).
*   `_plugins/`: Directory for custom Jekyll plugins.
*   `_posts/`: Directory where blog posts are stored. Each post is typically a Markdown file.
*   `_sass/`: Directory for Sass/SCSS files, used for styling.
*   `assets/`: Directory for static assets like images, CSS, JavaScript files.
*   `banner.js`: Likely a JavaScript file for a banner.
*   `favicon.ico`: The site's favicon.
*   `index.html`: The main entry point or homepage of the site.
*   `minimal-mistakes-jekyll.gemspec`: Ruby gem specification file for the Minimal Mistakes Jekyll theme.
*   `package-lock.json`: Records the exact versions of npm packages that were installed.
*   `package.json`: Lists npm package dependencies and project metadata for Node.js projects.
*   `robots.txt`: Tells search engine crawlers which pages or files the crawler can or can't request from your site.
*   `search.json`: Likely related to site search functionality.
*   `sitemap.xml`: An XML file that lists URLs for a site along with additional metadata about each URL.
*   `staticman.yml`: Configuration file for Staticman, a tool for handling user-generated content on static sites.

## Key Directories for Content and Customization

*   `_config.yml`: Site-wide settings, including author information, site title, URL, etc. This will be important for changing "2i" to "thakicloud".
*   `_data/`: May contain author details, navigation links, UI text.
*   `_includes/`: Reusable HTML components.
*   `_layouts/`: Defines the structure of different page types.
*   `_pages/`: Static pages like "About Us" or "Contact".
*   `_posts/`: All blog articles reside here.
*   `assets/`: Images, custom CSS/JS.

This structure is typical for a Jekyll-based blog using the Minimal Mistakes theme. 