---
title: "Industrial AI Models"
seo_title: "Industrial AI Model Hub - Motor Current, Equipment Sensor, Crack Vision and Equipment Command Research Models | ThakiCloud"
seo_description: "ThakiCloud's industrial AI research models on Hugging Face in one place: motor current fault classification, equipment sensor health, concrete crack detection, and equipment command proposals, with evaluation conditions, limits, and what to check before field use."
layout: posts
permalink: /en/industrial-ai/
lang: en
default_tag: industrial-ai
author_profile: true
sitemap: true
published: false
---

This page collects the industrial AI models ThakiCloud has published on Hugging Face. All of them are research previews, not product launches. Each model differs in data, evaluation method, and the nature of its labels, so the numbers below are not a ranking between models.

## Plain terms

These models are like new inspectors on a plant maintenance crew. They did well on tests at the training center, but none has worked the floor alone yet. So for each model we note which training center it was tested in, what the test was, and what has not been tested.

## At a glance

| Model | Input | What it does | Headline metric and evaluation condition | License |
|---|---|---|---|---|
| Thaki-MCSA-MantisV2-MCC5 | Three-phase motor current | Classifies 24 fault states | Macro-F1 0.943 on 71 sealed TEST recordings, single test rig | Apache-2.0 |
| Thaki-EquipmentHealth-Sensor-LGBM | Current, temperature and particulate sensors on transport vehicles | Sorts equipment health into four states | Macro F1 0.94 on unseen vehicles, labels from a testbed simulation | CC BY 4.0 |
| Thaki-FacilityVision-CrackCls-ResNet18 and CrackSeg-E2 | Concrete surface photos | Crack patch classification and pixel segmentation | Classification Macro F1 0.9993, segmentation Dice 0.8983, one public dataset | CC BY 4.0 |
| Thaki-FactoryShield-KO-7M | Korean equipment command sentences | Proposes commands without executing them, or refuses | Passed a synthetic sealed test only, no real field utterances evaluated | Custom research license |

## Model cards

### Thaki-MCSA-MantisV2-MCC5

- **Use**: A research model that separates normal from 23 fault states using only a motor's three-phase current. It fine-tunes the pretrained time-series model MantisV2.
- **Input and inference**: Current at 12.8kHz is cut into 65,536-sample windows, each phase becomes a 512-bin Welch log spectrum, and per-window probabilities are averaged to classify a recording.
- **Headline metric**: Macro-F1 0.943 on 71 sealed TEST recordings from 3 operating conditions never used in training. The development LOCO cross-validation score of 0.945 averages models retrained per fold; the released file is a single model retrained on all 208 development recordings.
- **Limits**: On the same TEST, a baseline using only the recording time scored 0.986, and one using only the date scored 0.127. There is only one test rig, so we do not claim generalization to other physical motors. 3 of the 4 errors confuse winding fault H and L.
- **Data**: MCC5-THU, Mendeley Data, CC BY 4.0.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-MCSA-MantisV2-MCC5) · post [MCSA model release](/tech-blog/en/research/thaki-mcsa-mantisv2-mcc5/)

### Thaki-EquipmentHealth-Sensor-LGBM

- **Use**: Sorts semiconductor-fab transport vehicles (OHT and AGV) into normal, attention, warning, and danger from sensor readings. The model is about 1 MB.
- **Headline metric**: Macro F1 0.94 on unseen vehicles, and none of 930 danger readings was called normal.
- **Limits**: Labels are not real failure records; they come from the dataset's testbed simulation system. We do not claim it predicts real failures. About one normal reading in twenty raises an attention alert.
- **Data**: AI Hub (AI-Hub) dataset 71802 (OHT and AGV equipment). The data is not redistributed.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-EquipmentHealth-Sensor-LGBM) · post [Equipment health from sensors](/tech-blog/en/research/thaki-equipmenthealth-sensor-paxis-maintenance/)

### Thaki-FacilityVision-CrackCls-ResNet18 and CrackSeg-E2

- **Use**: A classifier that picks crack patches from inspection photos (ResNet-18, about 11 million parameters) and a segmentation model that draws crack shapes at full resolution (U-Net with a ResNet-34 encoder, about 24 million parameters).
- **Headline metric**: The classifier scored Macro F1 0.9993 on 5,524 test patches. The segmentation model scored Dice 0.8983 and thin-crack recall 0.9139 on 60 development images.
- **Limits**: Measured on one public dataset only, so these are not field accuracy. The segmentation model's 61 test images have not been scored yet.
- **Data**: Ç. F. Özgenel, Mendeley Data, CC BY 4.0.
- **Links**: [CrackCls](https://huggingface.co/ThakiCloud/Thaki-FacilityVision-CrackCls-ResNet18) · [CrackSeg](https://huggingface.co/ThakiCloud/Thaki-FacilityVision-CrackSeg-E2) · post [Crack vision models](/tech-blog/en/research/thaki-facilityvision-crack-paxis-inspection/)

### Thaki-FactoryShield-KO-7M

- **Use**: Turns a Korean equipment command into a proposal made of an operation, an equipment ID and a delay, or refuses. It has 7,352,909 parameters, and `safe_to_actuate` in its output is always `false`.
- **Safety boundary**: The equipment ID the model picks is checked exactly against a registry of equipment IDs. If it is not in the registry, or no registry is given, the output is `ABSTAIN`.
- **Headline metric**: On the synthetic sealed test, model-only risk was 2.57 to 3.90%, and system risk with the validator and registry was 0.00 to 0.33%.
- **Limits**: All numbers come from synthetic data, and safety has never been validated in a real equipment environment.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-FactoryShield-KO-7M) · post [FactoryShield release](/tech-blog/en/agentops/thaki-factoryshield-ko-7m-paxis/)

## What the released models prove, and what they do not

Please read these three things separately.

**What the research models showed** is the result within the data and evaluation conditions on the cards above. The weights and evaluation contracts are public, so anyone can measure again under the same conditions.

**What the platform provides** is an operations layer that trains and serves models in the customer's environment (Metis), and an agent layer that ties model verdicts to reviewer checks, approvals, and work records (Paxis). The Paxis flows in each post are reference designs, not field measurements of these models running as an integrated product.

**What a field PoC has to check** is generalization to different equipment, performance against real failure records, false alarms and missed faults per hour of operation, and latency on field devices. Public data cannot answer these; they need the customer's equipment data and an evaluation design.

## If you are considering adoption

1. **Start with the equipment and the data.** Equipment type, sensor setup, sampling rate, and the conditions under which normal and fault records were collected come before choosing a model.
2. **Set the evaluation design.** Hold out equipment or time periods never used in training, and check that equipment IDs or collection times do not stand in for the answer.
3. **Get in touch.** If you want to assess this on your own equipment data, [contact ThakiCloud](/contact?interest=industrial-ai&origin=industrial-ai-hub).

## Related posts

The list below shows every post tagged `industrial-ai`. The main posts are:

- [We Released a Motor Current Signature Analysis (MCSA) Model](/tech-blog/en/research/thaki-mcsa-mantisv2-mcc5/)
- [Reading Equipment Health from Sensors, and Letting Paxis Open the Maintenance Work](/tech-blog/en/research/thaki-equipmenthealth-sensor-paxis-maintenance/)
- [Two Small Vision Models for Finding Concrete Cracks, Now Public](/tech-blog/en/research/thaki-facilityvision-crack-paxis-inspection/)
- [A 7M Model That Proposes Equipment Commands and Never Executes Them: Thaki-FactoryShield-KO-7M](/tech-blog/en/agentops/thaki-factoryshield-ko-7m-paxis/)
