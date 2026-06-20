---
title: "Sakana AI's RLT: Computers Learn How to Teach"
excerpt: "While earlier AI learned how to solve problems, the new RLT method learns how to teach, enabling even smaller and faster AI to achieve impressive results, much like a great teacher."
date: 2025-06-23
categories:
  - research
  - tutorials
tags:
  - reinforcement-learning
  - sakana-ai
  - rlt
  - ai-education
  - machine-learning
author_profile: true
toc: true
toc_label: "RLT Guide"
lang: en
canonical_url: "https://thakicloud.github.io/en/research/sakana-ai-rlt-reinforcement-learning-teachers-explained-for-kids/"
---

## Introduction

If you had to teach a math problem to a friend, how would you go about it? Would you just give them the answer? Or would you walk through the solution step by step?

The new research from **Sakana AI** introduced today starts from exactly that idea. Computers, just like people, can learn **how to teach**!

## The Problem with Existing AI: The Lone Learner

### Limitations of the Old Approach

Until now, smart AI systems studied like this:

- **Try to solve problems on their own**
- **Get rewarded when correct, and try again when wrong**
- **Repeat to build problem-solving ability**

What is wrong with this method?

1. **Too expensive and time-consuming**: only large computers can participate
2. **Good at only one domain**: if you only solve math problems, you struggle with everything else
3. **Hard to teach others**: knows the answer but cannot explain it well

It is like a math genius who cannot explain anything to their friends!

## The New Approach: RLT, the Teaching AI

### What Is RLT?

**RLT (Reinforcement Learning Teachers)** is AI that learns **how to teach**.

What makes it different from existing AI:
- **Given the problem and the answer in advance**
- **Practices explaining the solution process**
- **Is scored on whether the student understood**

### Comparing with a Real Teacher

| Good Teacher | RLT AI |
|---|---|
| Does not just recite theorems | Does not re-solve the problem from scratch |
| Explains so the student can understand | Explains so another AI can understand |
| Improves teaching based on student reactions | Measures performance by the student AI's comprehension |

## Remarkable Results from RLT

### The Birth of a Small Giant

The results from Sakana AI's experiments are truly surprising:

- A small RLT with **7 billion components** (7B parameters)
- **Outperforms** the massive DeepSeek R1 with **671 billion components** (671B parameters) as a teacher!

### Results by the Numbers

**Teaching a student AI of the same size:**
- RLT teacher: **26.3 points**
- DeepSeek R1 teacher: **18.9 points**

**Teaching a larger student AI:**
- RLT teacher: **37.6 points**
- DeepSeek R1 teacher: **34.4 points**

The small teacher even outperformed itself teaching a student four times its own size!

## Why RLT Is Special

### 1. Efficiency: Fast and Cheap

**Old method:**
- Months of training on large computers
- Large amounts of electricity and money required

**RLT method:**
- Training complete **in a single day**
- Possible even on small computers

### 2. Clear Explanations

**DeepSeek R1's explanations:**
- Describes how to use a calculator
- Includes jokes or unrelated remarks
- Complex and difficult expressions

**RLT's explanations:**
- Explains only the core points precisely
- Adds explanation for any missing steps
- Clear and direct language

### 3. Complementary, Not a Replacement

RLT does not completely replace the old approach; they work **better together**!

- Build foundational skills with RLT
- Finish with traditional reinforcement learning
- **Achieve higher results!**

## Understanding Through Everyday Examples

### Comparing to a Math Tutor

**Existing AI (problem-solving genius):**
```
Student: "How do I solve this problem?"
AI: "The answer is 42. I am not sure how I solved it either."
```

**RLT AI (teaching expert):**
```
Student: "How do I solve this problem?"
RLT: "Great! Let us look at this part first.
      Step 1: Multiply both sides by 2
      Step 2: Subtract 3
      Step 3: There is your answer!
      Does that make sense?"
```

## Future Outlook

### 1. Cheaper AI Education

- Building smart AI on small computers becomes possible
- Individuals and small companies can participate in AI development

### 2. AI That Teaches Itself

In the future, AI may play **teacher and student at the same time**!
- Learning by explaining to itself
- Continuously improving AI

### 3. Expansion into Diverse Fields

- Beyond math into science, language, and the arts
- Teaching AI capable of appearing in every field

## Summary

RLT has presented a new paradigm for AI development:

1. **Method matters more than size**
2. **The importance of teaching ability**
3. **Balancing efficiency and effectiveness**

Just as a small but excellent teacher can successfully teach much larger students, a small AI trained in the right way can also achieve great results.

When you teach someone, remember not to just give them the answer: explain things step by step so they can understand. That is what true teaching means, and AI is now learning that lesson too!

## References

- **Paper**: [Reinforcement Learning Teachers of Test Time Scaling](https://www.arxiv.org/abs/2506.08388)
- **Code**: [GitHub - SakanaAI/RLT](https://github.com/SakanaAI/RLT)
- **Original post**: [Sakana AI - RLT](https://sakana.ai/rlt/)
