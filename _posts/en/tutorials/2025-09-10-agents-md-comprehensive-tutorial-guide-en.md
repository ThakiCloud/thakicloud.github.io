---
title: "AGENTS.md: Complete Guide to Improving AI Code Output"
excerpt: "Learn how to create an effective AGENTS.md file that dramatically improves AI agent performance in your coding projects with practical examples and best practices."
seo_title: "AGENTS.md Tutorial: Improve AI Code Output with Best Practices - Thaki Cloud"
seo_description: "Complete guide to writing AGENTS.md files for better AI coding assistance. Includes dos/don'ts, safety rules, project structure, and real-world examples for optimal results."
date: 2025-09-10
categories:
  - tutorials
tags:
  - ai
  - coding
  - automation
  - productivity
  - agents
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/agents-md-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/agents-md-comprehensive-tutorial-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

If you've ever used an AI agent to generate code and thought, "this is so smart, and so dumb at the same time," this comprehensive guide is for you. A well-crafted `AGENTS.md` file can transform your AI coding experience from frustrating guesswork to consistent, high-quality output.

## Table of Contents

1. [What is AGENTS.md?](#what-is-agentsmd)
2. [The Problem: AI Without Context](#the-problem-ai-without-context)
3. [Step-by-Step AGENTS.md Creation](#step-by-step-agentsmd-creation)
4. [Advanced Configuration Strategies](#advanced-configuration-strategies)
5. [Real-World Examples](#real-world-examples)
6. [Complete AGENTS.md Template](#complete-agentsmd-template)
7. [Best Practices and Tips](#best-practices-and-tips)

## What is AGENTS.md?

AGENTS.md is a standardized markdown file placed at the root of your repository that provides AI tools with essential context about your project. Think of it as a "README for AI agents" that eliminates the need to repeat project-specific instructions in every prompt.

### Why AGENTS.md Matters

Unlike tool-specific configuration files (`.cursorrules`, `.builderrules`, etc.), AGENTS.md is becoming a universal standard supported by multiple AI coding tools:

- **Consistency**: Same rules apply across different AI tools
- **Efficiency**: No more repeating project context in every chat
- **Quality**: Better code output aligned with your standards
- **Scalability**: Works for teams and complex codebases

### Supported Tools

- Builder.io agents
- Cursor (via reference)
- Claude Projects
- GitHub Copilot Chat
- Replit Agent
- Many others through file lookup

## The Problem: AI Without Context

### Common Issues Without AGENTS.md

Let's examine what happens when AI agents lack project context:

#### Discovery Phase Overhead
```
User: "Add a dark mode toggle to the settings page"

AI Agent Process:
1. 🔍 Explores repository structure (burns time/tokens)
2. 🤔 Guesses framework and dependencies
3. 📝 Assumes coding conventions
4. 🎯 Produces generic solution
```

#### Typical Problems
- **Wrong library versions**: Uses MUI v4 syntax in v5 project
- **Inconsistent patterns**: `useState` instead of your preferred Redux/Zustand
- **Style conflicts**: Hard-coded colors instead of design tokens
- **Architectural mismatches**: Creates giant components instead of your modular approach
- **Tool confusion**: Generates complex workarounds instead of using built-in features

### Real Example: The Dark Mode Disaster

Without AGENTS.md, an AI might generate:

```jsx
// ❌ What AI produces without context
const DarkModeToggle = () => {
  const [isDark, setIsDark] = useState(false);
  
  return (
    <div style={% raw %}{{
      backgroundColor: isDark ? '#333' : '#fff',
      color: isDark ? '#fff' : '#333',
      padding: '16px'
    }}{% endraw %}>
      <button onClick={() => setIsDark(!isDark)}>
        Toggle Dark Mode
      </button>
    </div>
  );
};
```

**Problems:**
- Hard-coded colors (should use design tokens)
- Basic `useState` (should use your state management)
- Inline styles (should use your CSS-in-JS solution)
- Missing accessibility features

## Step-by-Step AGENTS.md Creation

### Step 1: Create the Basic Structure

Start with this minimal template:

```markdown
# AGENTS.md

### Do
- [Your preferred practices]

### Don't
- [Things to avoid]

### Commands
- [File-scoped commands]

### Safety and Permissions
- [What's allowed/restricted]

### Project Structure
- [Key file locations]
```

### Step 2: Define Your Dos and Don'ts

This is the most critical section. Be specific and opinionated:

```markdown
### Do
- Use React 18+ with TypeScript
- Use Tailwind CSS for styling with design tokens from `src/styles/tokens.ts`
- Use Zustand for state management with `create()` syntax
- Use Radix UI components as base layer
- Create small, focused components (max 100 lines)
- Use React Query for server state
- Prefer composition over inheritance
- Write JSDoc comments for complex functions

### Don't
- Use `any` type in TypeScript
- Hard-code colors, spacing, or breakpoints
- Create components larger than 100 lines
- Use `useEffect` for data fetching (use React Query)
- Mix business logic with UI components
- Use `div` when semantic HTML exists
- Add new dependencies without approval
```

### Step 3: Set Up File-Scoped Commands

Avoid slow project-wide builds with targeted commands:

```markdown
### Commands

# Type check single file
npx tsc --noEmit path/to/file.tsx

# Format single file
npx prettier --write path/to/file.tsx

# Lint single file with fix
npx eslint --fix path/to/file.tsx

# Run specific test file
npm run test path/to/file.test.tsx

# Full project build (use sparingly)
npm run build

Note: Always run type checking, formatting, and linting on modified files.
Only run full builds when explicitly requested.
```

### Step 4: Configure Safety and Permissions

Control what the AI can do autonomously:

```markdown
### Safety and Permissions

Allowed without asking:
- Read any project files
- Run linting, formatting, type checking on single files
- Run unit tests for specific files
- Create/modify component files in `src/components/`
- Update documentation files

Require approval before:
- Installing new npm packages
- Modifying package.json, tsconfig.json, or config files
- Running full project builds or e2e tests
- Deleting files or changing file permissions
- Making git commits or pushes
- Modifying CI/CD workflows
```

### Step 5: Document Project Structure

Provide a roadmap for navigation:

```markdown
### Project Structure

Key directories:
- `src/components/` - Reusable UI components
- `src/pages/` - Page-level components
- `src/hooks/` - Custom React hooks
- `src/utils/` - Pure utility functions
- `src/types/` - TypeScript type definitions
- `src/styles/` - Styling and design tokens

Important files:
- `src/App.tsx` - Main application component
- `src/routes.tsx` - Application routing
- `src/styles/tokens.ts` - Design system tokens
- `src/utils/api.ts` - API client configuration
```

### Step 6: Provide Concrete Examples

Show good and bad patterns from your actual codebase:

```markdown
### Good and Bad Examples

✅ Good patterns:
- Components: Follow `src/components/Button/Button.tsx` structure
- API calls: Use patterns from `src/hooks/useUsers.ts`
- Forms: Copy approach from `src/components/ContactForm.tsx`
- Styling: Reference `src/components/Card/Card.tsx`

❌ Avoid these patterns:
- Legacy class components in `src/legacy/`
- Direct fetch() calls (use React Query instead)
- Inline styles (use Tailwind classes)
- Hardcoded API URLs (use environment variables)
```

## Advanced Configuration Strategies

### API Documentation Integration

```markdown
### API Reference

Base URL: Use `VITE_API_BASE_URL` environment variable

Endpoints:
- GET /api/users - List users (paginated)
- POST /api/users - Create user
- GET /api/users/:id - Get user details
- PATCH /api/users/:id - Update user

Authentication: Bearer token via `useAuth()` hook
Error handling: Use `ApiError` class from `src/utils/errors.ts`

Examples: See `src/hooks/api/` for usage patterns
```

### Test-First Development Mode

```markdown
### Test-First Mode

For new features:
1. Write failing tests first using Jest and React Testing Library
2. Implement minimal code to pass tests
3. Refactor while keeping tests green

Test patterns:
- Component tests: Follow `src/components/Button/Button.test.tsx`
- Hook tests: Follow `src/hooks/useLocalStorage/useLocalStorage.test.ts`
- Integration tests: Use MSW for API mocking

Coverage requirements: Maintain >80% for new code
```

### Design System Integration

```markdown
### Design System

Components: Use components from `@company/design-system`
Tokens: Import from `@company/design-system/tokens`

Available components:
- Button: `<Button variant="primary" size="md" />`
- Input: `<Input placeholder="Enter text" error="Error message" />`
- Modal: `<Modal isOpen={true} onClose={handleClose} />`

Documentation: See `docs/design-system/` for full API
Figma: Components match Figma library exactly

Custom styling: Only extend, never override design system styles
```

### PR and Code Review Guidelines

```markdown
### Pull Request Checklist

Before creating PR:
- [ ] All tests pass locally
- [ ] Code formatted with Prettier
- [ ] No TypeScript errors
- [ ] No linting warnings
- [ ] Components documented with JSDoc
- [ ] Accessible according to WCAG 2.1 AA

PR requirements:
- Small, focused changes (< 400 lines)
- Clear description of changes
- Screenshots for UI changes
- Performance impact noted if applicable

Review criteria:
- Code follows established patterns
- Proper error handling
- Responsive design implementation
- Cross-browser compatibility considered
```

## Real-World Examples

### Example 1: E-commerce Project

```markdown
# AGENTS.md

### Do
- Use Next.js 14+ with App Router
- Use Shopify Storefront API with GraphQL
- Use Tailwind CSS with custom design tokens
- Use React Hook Form for forms with Zod validation
- Use Framer Motion for animations
- Create responsive designs (mobile-first)
- Optimize images with Next.js Image component

### Don't
- Use Pages Router (use App Router)
- Bypass form validation
- Use third-party animation libraries other than Framer Motion
- Hard-code product IDs or API keys

### Commands
npx next lint --fix --file path/to/file.tsx
npx prettier --write path/to/file.tsx
npm run type-check
npm run test:unit path/to/file.test.tsx

### Project Structure
- `app/` - Next.js App Router pages
- `components/` - Reusable UI components
- `lib/shopify/` - Shopify API integration
- `hooks/` - Custom React hooks for cart, user, etc.

### Good Examples
- Product pages: `app/products/[handle]/page.tsx`
- Cart logic: `hooks/useCart.ts`
- Form handling: `components/ContactForm.tsx`
```

### Example 2: SaaS Dashboard

```markdown
# AGENTS.md

### Do
- Use React 18 with TypeScript
- Use React Query for server state
- Use React Router v6 for navigation
- Use Chart.js for data visualization
- Use React Hook Form + Yup for forms
- Follow atomic design principles
- Implement proper error boundaries

### Don't
- Use class components
- Mix business logic in UI components
- Create components without proper TypeScript types
- Use inline event handlers in JSX

### API Integration
Base URL: `process.env.REACT_APP_API_URL`
Authentication: JWT tokens via `useAuth()` hook

Key endpoints:
- `/dashboard/metrics` - Dashboard data
- `/users/profile` - User information
- `/projects` - Project CRUD operations

### Performance Requirements
- Bundle size < 1MB gzipped
- First Contentful Paint < 2s
- Time to Interactive < 3s
- Lighthouse score > 90
```

## Complete AGENTS.md Template

Here's a comprehensive template you can customize for your project:

```markdown
# AGENTS.md

## Project Overview
Brief description of the project, tech stack, and goals.

### Do
- Use [Framework] version X.Y+
- Use [State Management] for application state
- Use [Styling Solution] with design tokens from [location]
- Use [Component Library] as base components
- Follow [Architecture Pattern] for component structure
- Create small, focused components (max [X] lines)
- Use [Testing Library] for all tests
- Implement proper error handling and loading states
- Follow accessibility guidelines (WCAG 2.1 AA)

### Don't
- Use deprecated APIs or patterns
- Hard-code values (use constants/environment variables)
- Create large, monolithic components
- Mix business logic with presentation
- Skip error handling or loading states
- Use `any` type in TypeScript
- Add dependencies without team approval

### Commands

# Development commands
npm run dev                              # Start development server
npm run type-check                       # TypeScript type checking
npm run lint:check                       # Run linter
npm run lint:fix                         # Fix linter issues
npm run format                           # Format with Prettier

# File-scoped commands (preferred)
npx tsc --noEmit path/to/file.tsx        # Type check single file
npx eslint --fix path/to/file.tsx        # Lint single file
npx prettier --write path/to/file.tsx    # Format single file

# Testing
npm run test                             # Run all tests
npm run test:watch                       # Watch mode
npm run test path/to/file.test.tsx       # Run specific test
npm run test:coverage                    # Coverage report

# Build and deployment
npm run build                            # Production build
npm run preview                          # Preview production build

Note: Prefer file-scoped commands for faster feedback loops.

### Safety and Permissions

Allowed without prompt:
- Read project files and documentation
- Run development server locally
- Execute linting, formatting, and type checking
- Run unit tests for specific files or components
- Create/modify component files following project structure
- Update component documentation and README files

Ask permission before:
- Installing or updating npm packages
- Modifying configuration files (package.json, tsconfig.json, etc.)
- Running full project builds or end-to-end tests
- Making changes to CI/CD workflows
- Deleting files or changing file permissions
- Committing to version control or pushing changes
- Modifying database schemas or API contracts

### Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── ui/             # Base UI components (buttons, inputs, etc.)
│   ├── forms/          # Form-specific components
│   └── layout/         # Layout components (header, sidebar, etc.)
├── pages/              # Page-level components
├── hooks/              # Custom React hooks
├── services/           # API calls and external services
├── utils/              # Pure utility functions
├── types/              # TypeScript type definitions
├── constants/          # Application constants
├── styles/             # Global styles and design tokens
└── tests/              # Test utilities and setup
```

Key files:
- `src/App.tsx` - Main application component
- `src/main.tsx` - Application entry point
- `src/router.tsx` - Application routing configuration
- `src/styles/globals.css` - Global styles and CSS variables
- `src/types/index.ts` - Shared TypeScript types
- `src/utils/api.ts` - API client configuration

### Good and Bad Examples

✅ Follow these patterns:
- Component structure: `src/components/ui/Button/Button.tsx`
- Custom hooks: `src/hooks/useLocalStorage/useLocalStorage.ts`
- API integration: `src/services/userService.ts`
- Form handling: `src/components/forms/LoginForm.tsx`
- Error boundaries: `src/components/ErrorBoundary.tsx`

❌ Avoid these patterns:
- Legacy class components in `src/legacy/`
- Direct API calls in components (use services instead)
- Inline styles (use CSS modules or styled-components)
- Massive components (break down into smaller pieces)

### API Documentation

Base URL: `process.env.VITE_API_BASE_URL`
Authentication: Bearer tokens via `useAuth()` hook

Common endpoints:
- `GET /api/users` - Fetch users list
- `POST /api/users` - Create new user
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

Error handling: Use `ApiError` class from `src/utils/errors.ts`
Response format: All endpoints return `{ data, error, message }` structure

### Design System

Component library: [Library Name] v[X.Y.Z]
Design tokens: Import from `src/styles/tokens.ts`
Icons: Use `@heroicons/react` or `lucide-react`

Available components:
- `<Button variant="primary|secondary|outline" size="sm|md|lg" />`
- `<Input type="text|email|password" error="Error message" />`
- `<Modal isOpen={boolean} onClose={function} title="Modal Title" />`
- `<Toast type="success|error|warning|info" message="Toast message" />`

Theming: Support light/dark modes via CSS custom properties
Responsive: Mobile-first approach with defined breakpoints

### Testing Guidelines

Framework: Jest + React Testing Library
Coverage: Maintain >80% for new code
Test types:
- Unit tests: Test individual components/functions
- Integration tests: Test component interactions
- E2E tests: Test critical user journeys (Playwright)

Test file naming:
- `ComponentName.test.tsx` for component tests
- `utils.test.ts` for utility function tests
- `hooks.test.ts` for custom hook tests

Mocking:
- API calls: Use MSW (Mock Service Worker)
- External services: Mock in `src/tests/mocks/`
- Environment variables: Override in test setup

### Performance Guidelines

Bundle size targets:
- Main bundle: < 250KB gzipped
- Total initial load: < 1MB gzipped

Core Web Vitals targets:
- Largest Contentful Paint (LCP): < 2.5s
- First Input Delay (FID): < 100ms
- Cumulative Layout Shift (CLS): < 0.1

Optimization strategies:
- Use React.lazy() for code splitting
- Implement proper image optimization
- Use React.memo() for expensive components
- Minimize re-renders with useMemo/useCallback

### Pull Request Guidelines

PR size: Keep changes under 400 lines when possible
Commit messages: Follow conventional commits format

Required checks before PR:
- [ ] All tests pass locally
- [ ] No TypeScript errors
- [ ] No linting warnings
- [ ] Components are properly documented
- [ ] Performance impact assessed
- [ ] Accessibility requirements met

PR description should include:
- Summary of changes
- Screenshots for UI changes
- Testing instructions
- Breaking changes (if any)

### Error Handling

Global error boundary: Catches unhandled React errors
API errors: Standardized error responses with proper HTTP codes
Form validation: Client-side validation with server-side backup
Loading states: Show appropriate loading indicators

Error reporting: Use Sentry for production error tracking
User messaging: Show user-friendly error messages

### Accessibility Requirements

WCAG 2.1 AA compliance required for all components
Tools: Use axe-core for automated testing

Key requirements:
- Proper semantic HTML
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios ≥ 4.5:1
- Focus management for modals/dropdowns
- Alternative text for images

### Environment Configuration

Development: `npm run dev` starts local development server
Staging: Deployed automatically on push to `develop` branch
Production: Deployed automatically on push to `main` branch

Environment variables:
- `VITE_API_BASE_URL` - API endpoint URL
- `VITE_APP_ENV` - Environment identifier
- `VITE_SENTRY_DSN` - Error reporting configuration

### When Stuck

If unsure about implementation details:
1. Ask clarifying questions about requirements
2. Propose a brief implementation plan
3. Reference similar patterns in the codebase
4. Create a draft PR with comments for discussion

Don't make large speculative changes without confirmation.

### Additional Resources

- Project documentation: `/docs/`
- Component Storybook: `npm run storybook`
- API documentation: `/docs/api.md`
- Contributing guidelines: `/CONTRIBUTING.md`
- Code style guide: `/docs/style-guide.md`
```

## Best Practices and Tips

### 1. Start Small and Iterate

Begin with a minimal AGENTS.md focused on your biggest pain points:

```markdown
# AGENTS.md - v1.0

### Do
- Use TypeScript for all new code
- Follow existing component patterns

### Don't
- Use `any` types
- Create files larger than 200 lines

### Commands
npx tsc --noEmit path/to/file.tsx
```

Then expand based on AI behavior you want to change.

### 2. Use Concrete Examples

Instead of abstract rules, point to actual files:

```markdown
❌ Abstract: "Follow good component patterns"
✅ Concrete: "Copy structure from src/components/Button/Button.tsx"
```

### 3. Be Opinionated and Specific

Don't just say "use best practices" - define what that means for your project:

```markdown
❌ Vague: "Write good tests"
✅ Specific: "Test components with React Testing Library, mock API calls with MSW"
```

### 4. Version Your AGENTS.md

As your project evolves, so should your AI instructions:

```markdown
# AGENTS.md - v2.1

<!-- Changelog:
v2.1 - Added React Query patterns
v2.0 - Migrated to TypeScript
v1.0 - Initial version
-->
```

### 5. Team Collaboration

Make AGENTS.md a living document that the team maintains:

- Regular reviews during retrospectives
- Updates when adopting new tools/patterns
- Shared ownership across team members

### 6. Tool-Specific Adaptations

For tools that don't support AGENTS.md natively:

```markdown
# .cursorrules
Strictly follow all rules and guidelines in ./AGENTS.md

# claude.md  
Please follow the project guidelines specified in AGENTS.md
```

### 7. Measure and Adjust

Track the impact of your AGENTS.md:

- **Before/After comparisons**: Save examples of AI output before and after
- **Team feedback**: Regular check-ins on AI assistance quality
- **Iteration cycles**: Update rules based on recurring issues

### 8. Common Pitfalls to Avoid

**Too Long**: Keep it focused - long files get ignored
```markdown
❌ 50+ rules covering every edge case
✅ 10-15 key rules that solve 80% of problems
```

**Too Vague**: Be specific about your requirements
```markdown
❌ "Use good error handling"
✅ "Use try-catch blocks with ApiError class for all API calls"
```

**Tool-Specific**: Focus on general principles
```markdown
❌ "Use Cursor's auto-complete feature"
✅ "Prefer explicit imports over wildcard imports"
```

**Static Rules**: Update as your project evolves
```markdown
✅ Regular reviews and updates based on new patterns
```

## Advanced Tips for Power Users

### 1. Context-Aware Rules

Create conditional guidelines based on the type of work:

```markdown
### Context-Specific Guidelines

For new features:
- Write tests first (TDD approach)
- Start with TypeScript interfaces
- Create Storybook stories for UI components

For bug fixes:
- Add regression tests
- Document the root cause
- Update related documentation

For refactoring:
- Maintain existing API contracts
- Update tests to reflect changes
- Use deprecation warnings for breaking changes
```

### 2. Integration with Development Workflow

```markdown
### Workflow Integration

Pre-commit hooks:
- Run `npm run lint:fix` on staged files
- Run `npm run type-check` on TypeScript files
- Run relevant tests for changed files

CI/CD considerations:
- All AGENTS.md rules are enforced in CI
- Failed checks block PR merging
- Performance budgets are monitored
```

### 3. Metrics and Monitoring

```markdown
### Quality Metrics

Track these metrics for code quality:
- Bundle size impact (use webpack-bundle-analyzer)
- TypeScript strict mode compliance
- Test coverage percentage
- Accessibility violations (use axe-core)
- Performance scores (Lighthouse CI)

Acceptable thresholds:
- Bundle size increase: < 5% per PR
- Test coverage: > 80% for new code
- Performance score: > 90 for critical pages
```

## Conclusion

A well-crafted AGENTS.md file is a game-changer for AI-assisted development. It transforms your AI tools from generic code generators into project-aware assistants that understand your specific requirements, constraints, and preferences.

### Key Takeaways

1. **Start Simple**: Begin with basic dos/don'ts and expand over time
2. **Be Specific**: Use concrete examples and file references
3. **Stay Current**: Regular updates as your project evolves
4. **Team Ownership**: Make it a shared responsibility
5. **Measure Impact**: Track improvements in AI output quality

### Next Steps

1. **Create Your First AGENTS.md**: Start with the template provided
2. **Test with Your AI Tools**: Run typical prompts and compare results
3. **Iterate Based on Results**: Refine rules based on AI behavior
4. **Share with Your Team**: Get input and establish maintenance process
5. **Monitor and Improve**: Regular reviews and updates

Remember: The goal isn't to write perfect AI instructions from day one. It's to create a foundation that improves your development experience and gradually becomes more refined as you learn what works best for your specific project and team.

### Additional Resources

- [AGENTS.md GitHub Repository](https://github.com/AI-Engineer-Foundation/agents.md)
- [Builder.io Blog Post](https://www.builder.io/blog/agents-md)
- [Community Examples](https://github.com/topics/agents-md)

Happy coding with AI! 🚀

---

*This tutorial is part of our comprehensive AI development series. Check out our other tutorials on AI-assisted development, automation, and productivity tools.*
