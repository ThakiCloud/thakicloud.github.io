---
title: "NVIDIA Granary: A Large-Scale Multilingual Speech Dataset Spanning 25 European Languages"
excerpt: "NVIDIA's latest multilingual speech recognition and translation dataset, Granary, covers 640,000 hours of audio across 25 European languages. This guide covers its key characteristics and practical uses."
seo_title: "NVIDIA Granary Multilingual Speech Dataset Comprehensive Guide - Thaki Cloud"
seo_description: "A detailed look at NVIDIA Granary: 25 European languages, 640,000 hours of audio, dataset structure, and how to use it for ASR and AST tasks."
date: 2025-08-19
last_modified_at: 2025-08-19
categories:
  - datasets
tags:
  - nvidia
  - granary
  - 음성인식
  - 다언어
  - ASR
  - AST
  - 음성번역
  - 데이터셋
  - NeMo
  - 허깅페이스
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/datasets/nvidia-granary-multilingual-speech-dataset-comprehensive-guide/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 8 min

## Introduction

As speech AI technology advances rapidly, high-quality speech datasets that support a wide range of languages are becoming increasingly important. Building global services in particular requires multilingual speech processing capabilities rather than single-language coverage. Against this backdrop, the **Granary dataset** released by NVIDIA marks a new milestone for the speech AI field.

Granary is a large-scale multilingual dataset providing a total of 640,000 hours of audio across 25 European languages. It supports not only automatic speech recognition (ASR) but also automatic speech translation (AST), giving researchers and developers a rich foundation for building next-generation multilingual speech AI models.

![Conceptual image of speech data in 25 European languages converging into a single multilingual speech-AI foundation](/assets/images/nvidia-granary-multilingual-speech-dataset-comprehensive-guide-hero.png)

## Overview of the NVIDIA Granary Dataset

### Scale and Breadth

The most striking characteristic of the Granary dataset is its size. **640,000 hours** of speech data dwarfs existing publicly available datasets. This corresponds to roughly 73 years of continuous playback, providing an average of more than 25,000 hours of data per language.

The dataset covers **25 European languages**, ranging from major languages such as German, English, French, Spanish, and Italian to relatively lower-resource languages such as Bulgarian, Latvian, and Slovenian. This broad language coverage makes it possible to develop speech AI systems that can be deployed across the entire European region.

### Two Core Task Types Supported

Granary supports both of the two key tasks in modern speech AI:

**Automatic Speech Recognition (ASR)**
This task converts speech in a given language into text in that same language, for example converting German audio into German text. Granary provides ASR data for all 25 languages and contains a total of **643,000 hours** of ASR data.

**Automatic Speech Translation (AST)**
This task directly translates speech in a source language into text in a different target language. Granary provides AST data for 24 non-English languages translated into English text, amounting to a total of **351,000 hours** of AST data.

## Data Composition and Sources

### Integration of Four Major Corpora

The power of Granary comes from the systematic integration of four major speech corpora, each with distinct characteristics:

**YODAS (YouTube-Over-Dataset Audio Segmentation)**
Developed at Carnegie Mellon University (CMU), this dataset provides **192,000 hours** of data across 23 languages. YODAS is characterized by natural speech extracted from real YouTube content, reflecting diverse accents, speaking styles, and background noise conditions that arise in real-world environments.

**VoxPopuli**
Based on European Parliament session recordings, this dataset provides **206,000 hours** of high-quality political discourse data across 24 languages. It features formal, clearly articulated speech and is valuable for learning standard pronunciation and grammar across a variety of European languages.

**YouTube-Commons**
Collected from diverse YouTube content, this dataset contains **122,000 hours** of data across 24 languages. It spans genres including education, entertainment, and news, and captures the variety of language found in real-world usage.

**LibriLight**
An English-only dataset providing **23,000 hours** of English speech. Based on audiobook readings, it offers clear and standard English pronunciation, serving as a benchmark for English ASR models.

### Data Quality Control

Each corpus went through a rigorous quality control process. For speech recognition, accuracy was guaranteed through a two-stage Whisper model inference pipeline and language identification verification. Additional preprocessing steps such as speech segmentation, noise reduction, and metadata consistency checks were applied to select only the highest-quality data.

For speech translation data, high-quality translations were produced using the EuroLLM-9B model and verified through cross-lingual validation. Further quality control measures including hallucination detection and character-rate filtering were also applied.

![NVIDIA Granary data pipeline: from four corpora through quality control to Granary and NeMo](/assets/images/nvidia-granary-multilingual-speech-dataset-comprehensive-guide-diagram.svg)

## Data Structure and Access

### Flexible Data Configurations

Granary is designed with a highly flexible structure to accommodate diverse user requirements. Data can be accessed through a total of **76 configurations**, organized in two main ways:

**Language-based access**
All corpus data for a specific language can be retrieved at once. For example, if German data is needed, all German-related data (from YODAS, VoxPopuli, YouTube-Commons, etc.) can be retrieved in one combined pull.

**Corpus-based access**
Data from a specific corpus for a specific language can be selected individually. For example, if only formal language is needed, just the VoxPopuli data can be selected; if natural conversational speech is needed, only the YouTube-based data can be used.

### Practical Data Format

Each data sample includes all the metadata needed for real-world speech AI development:

- **Audio file path**: Location of the actual audio file
- **Transcript text**: Accurate text transcription in the source language
- **Duration**: Audio length, useful for optimizing batch processing
- **Language information**: Source and target language codes
- **Task type**: ASR or AST designation
- **Unique identifier**: ID for data tracing and reproducibility
- **Target text**: Transcription for ASR, or English translation for AST

This detailed metadata allows researchers to filter data by specific conditions or to reproduce experimental results precisely.

## Seamless Integration with the NeMo Toolkit

### Ready-to-Use Manifest Files

One of the most practical aspects of Granary is its seamless integration with the NVIDIA NeMo toolkit. Manifest files are provided so that downloaded data can be used in a NeMo environment immediately, without any complex conversion steps.

Because separate manifest files are provided for each language and corpus combination, researchers can select exactly the dataset that matches their research goals and start model training right away. For example, to develop a German speech recognition model, a German ASR manifest file can be used to begin training immediately.

### Optimization for Large-Scale Training

Training high-performance models for industrial use typically requires data in an optimized format such as WebDataset. Granary was designed with this requirement in mind and can be easily converted to WebDataset format using the conversion tools provided with NeMo.

This enables efficient data loading even in large-scale distributed training across hundreds of GPUs, and allows memory usage and I/O performance to be optimized.

### Extending to New Languages

Beyond providing a finished dataset, Granary also supplies the tools to generate datasets for new languages using the same pipeline. Through NeMo-speech-data-processor, researchers can produce their own language- or domain-specific speech datasets at the same quality level as Granary.

## Applications

### Multilingual Speech Recognition Systems

The most direct application of Granary is in the development of multilingual speech recognition systems. Whereas individual language-specific models were previously required, the unified data structure of Granary makes it possible to develop a single model that supports multiple languages simultaneously.

This is particularly valuable for companies serving European markets. A single model supporting all 25 languages can substantially reduce development and maintenance costs, and cross-lingual transfer learning can also improve performance on individual languages.

### Real-Time Speech Translation Services

The AST data can be used to build real-time speech translation services, which are applicable in international conferences, tourism, education, and many other domains.

The translation data for 24 languages into English provided by Granary is especially practical given the role English plays as an international lingua franca. It enables the development of tools through which speakers of diverse European languages can communicate in real time with English-speaking audiences.

### Low-Resource Language Research

Granary includes languages such as Bulgarian, Latvian, and Slovenian that have relatively limited available data. Large-scale speech data for these languages can make an important contribution to low-resource language processing research.

Researchers can study transfer learning techniques from high-resource languages (such as German or French) to low-resource languages, or analyze how multilingual models learn commonalities and differences across languages.

### Domain Adaptation Research

The four corpora in Granary each have different characteristics. VoxPopuli contains formal political discourse, YouTube data contains everyday conversational speech, and LibriLight contains standard read speech. This variety is valuable for domain adaptation research.

Researchers can analyze how a model trained in one domain performs in another, or conduct studies developing more robust models by mixing data from multiple domains.

## License and Accessibility

### Open License Policy

The Granary dataset is provided under the **CC-BY-4.0** license, which is a very open license permitting almost all uses including commercial applications. The only requirement is appropriate attribution.

This open licensing encourages use not only in academic research but also in industry. Anyone from startups to large enterprises can use this dataset to develop speech AI products.

### Easy Access via Hugging Face

The dataset is distributed through the Hugging Face platform, making it easily accessible from anywhere in the world. The data can be downloaded with just a few lines of code, with no complex application or approval process.

Streaming is also supported, allowing users to work with only the portions they need in real time without downloading the entire dataset. This is especially convenient in research environments with limited storage.

## Technical Innovation and Quality Assurance

### Use of State-of-the-Art AI Technologies

The production of the Granary dataset employed state-of-the-art AI technologies throughout. Speech recognition used a two-stage Whisper model inference pipeline, and translation used the EuroLLM-9B model.

The use of these technologies means that the dataset not only increased in volume but also substantially surpasses previous datasets in terms of quality. Advanced techniques such as hallucination detection, quality estimation filtering, and cross-lingual validation ensure a high level of reliability.

### Multi-Stage Quality Management System

Data quality management is carried out systematically across multiple stages, with strict verification at every level: accuracy of speech segmentation, accuracy of transcription, quality of translation, and consistency of metadata.

This multi-stage quality management system means that researchers can focus directly on model development without spending time on data preprocessing. Using data processed to a consistent quality standard also greatly improves the reproducibility and comparability of experimental results.

## Research Collaboration and Community Contribution

### A Model of Industry-Academia Collaboration

The Granary project emerged from collaboration among NVIDIA, Carnegie Mellon University (CMU), and Fondazione Bruno Kessler (FBK) in Italy. It represents an exemplary combination of industry technical capabilities, academic research expertise, and international cooperation.

By having each institution contribute in its area of strength, the project achieved a dataset of a scale and quality that would have been difficult for any single organization to produce alone. This collaboration model should serve as a useful reference for future large-scale AI projects.

### Open Science in Practice

The public release of Granary is a strong example of the open science principle in action. Making a high-quality dataset produced at considerable cost and effort available under an open license contributes to the advancement of the global research community.

This openness in turn invites feedback and contributions from the research community, which will lead to continuous improvement of the dataset and the discovery of new applications.

## Future Directions

### Potential for Language Expansion

Granary currently supports 25 European languages, but it demonstrates the potential for the same pipeline to be extended to other language families. Expansion to Asian languages, African languages, Indigenous American languages, and others could form the foundation for a truly global multilingual speech AI.

In particular, building a comparable dataset for East Asian languages such as Korean, Japanese, and Chinese could make a major contribution to speech AI development in the Asian region.

### Addition of New Task Types

While the current focus is on ASR and AST, there is potential for expansion to various other speech-related tasks such as speech emotion recognition, speaker identification, and speech synthesis data. New tasks could be supported by adding additional annotations to the high-quality audio data already collected.

### Optimization for Real-Time Processing

The current large-scale dataset is primarily intended for offline training, but in the future, optimized subsets or lightweight versions designed for real-time speech processing may become available. This could make high-quality multilingual speech recognition feasible on mobile devices and in edge computing environments.

## Conclusion

The NVIDIA Granary dataset goes beyond simply being a large dataset; it is a resource that opens up new possibilities for multilingual speech AI. The 640,000 hours of high-quality speech data across 25 languages enables researchers and developers to conduct experiments and development at a scale that was previously not possible.

Systematic quality control, seamless integration with the NeMo toolkit, and an open license policy make this dataset a genuinely practical resource. The development process built on industry-academia collaboration and the embodiment of the open science principle provide valuable guidance for the direction of AI research going forward.

A variety of research outcomes leveraging Granary will emerge in the coming years, leading in turn to further advances in multilingual speech AI technology. The technical foundation for an era of truly global communication that transcends language barriers is being built here.

## References

- [nvidia/Granary (Hugging Face)](https://huggingface.co/datasets/nvidia/Granary) - Dataset (CC-BY-4.0)
- [Granary paper (arXiv:2505.13404, Interspeech 2025)](https://arxiv.org/abs/2505.13404)
- [NVIDIA NeMo Toolkit](https://github.com/NVIDIA/NeMo)
- Component corpora: [YODAS](https://arxiv.org/abs/2406.00899) · [VoxPopuli](https://arxiv.org/abs/2101.00390) · [LibriLight](https://arxiv.org/abs/1912.07875)
