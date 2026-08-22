---
title: "Switch off the OpenAI Realtime API in one line: hugging-voice, an open voice stack you run yourself"
excerpt: "Hugging Face's hugging-voice and its engine speech-to-speech wrap a full realtime voice pipeline, from VAD through STT, LLM, and TTS, behind an OpenAI Realtime compatible WebSocket. Change one line in your client's base URL and you move onto your own infrastructure. We took the design apart from a serving perspective."
date: 2026-07-21
tags:
  - speech-to-speech
  - realtime-voice
  - VoiceAI
  - OpenAIRealtime
  - STT
  - TTS
  - LLM-serving
  - LLMOps
  - on-prem
  - self-hosting
author_profile: true
toc: true
toc_label: Anatomy of the realtime voice stack
lang: en
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/hugging-voice-open-realtime-voice-self-hosted/"
published: false
---

![An open realtime voice pipeline you run yourself]({{ '/assets/images/hugging-voice-open-realtime-voice-self-hosted-hero.webp' | relative_url }})

This post is for engineers who wanted to add a voice agent but hesitated at the lock-in and cost of the OpenAI Realtime API, and for infrastructure owners weighing whether conversational voice can be served on their own stack. The short version is that the design of Hugging Face's demo [hugging-voice](https://huggingface.co/spaces/HuggingFaceM4/hugging-voice) and the library beneath it, [speech-to-speech](https://github.com/huggingface/speech-to-speech), is both simple and practical. It opens the entire four-stage realtime voice pipeline as open source, while wrapping the outside in the very same interface as OpenAI Realtime. So if you already have code written against an OpenAI realtime client, you can move onto your own stack by changing a single line: the address the server points to. We only cite performance figures within the range the project has published, and we note up front that these are not numbers we benchmarked ourselves.

## Overview

Over the past year, conversational voice has stopped being a side feature of text chatbots and become a product category of its own. Users speak, and they expect the reply to come back instantly, the way a human conversation flows. The problem is that the commercial path to meeting that expectation has effectively converged on a handful of closed services like the OpenAI Realtime API. Convenient, yes, but voice traffic tends to be billed by the second rather than by the token, data leaves your walls, and both the model and the voices are tied to the provider.

hugging-voice arrives as a counterexample to that trend. The subtitle of the Space says it directly: "An Open Realtime Voice You Can Actually Run Yourself." The core idea is that the whole round trip, turning the voice arriving at the microphone into text, sending it to a language model, and turning the reply back into speech, is opened as a pipeline whose every component can be swapped. For those of us who serve models in on-prem and sovereign environments, it means there is now a concrete reference implementation for the question "can realtime voice run on our own cluster?"

## What hugging-voice and speech-to-speech are

To settle the terms first: hugging-voice is the demo Space where you can speak to it directly in the browser, and the engine that actually processes the voice inside it is the speech-to-speech library. The library splits a realtime voice agent into four stages: voice activity detection (VAD), speech-to-text (STT), a language model (LLM), and text-to-speech (TTS). Each stage runs in a separate thread and is connected by queues, so the output of one stage streams into the next. A partial transcript appears before the user has finished speaking, and speech synthesis begins on the opening words before the model has finished the sentence, which cuts perceived latency.

<div class="mermaid">
flowchart TB
    A["Microphone input<br/>realtime audio stream"] --> B["VAD speech detection<br/>Silero VAD v5"]
    B --> C["STT recognition<br/>Parakeet TDT · Whisper etc."]
    C --> D["LLM response<br/>OpenAI-compatible API · vLLM · llama.cpp"]
    D --> E["TTS synthesis<br/>Qwen3-TTS · Kokoro etc."]
    E --> F["Speaker output<br/>streaming playback"]
    G["OpenAI Realtime compatible<br/>WebSocket server"] -.- B
    G -.- C
    G -.- D
    G -.- E
</div>

In this diagram, the WebSocket server on the right is the project's real weapon. Simply gluing four stages together is not new. What sets speech-to-speech apart is that it wraps the entire pipeline in a WebSocket endpoint compatible with the OpenAI Realtime protocol. That lets an existing OpenAI realtime client connect to this server as if it were OpenAI itself. It is worth noting that this stack is not an experimental toy: it runs the realtime voice infrastructure of Hugging Face's Reachy Mini robots in production.

## Switching over in one line

This is the part the project itself calls "one-line migration." The only thing a client that used OpenAI Realtime has to change is the connection address. Below is the Python client example the project documentation offers.

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8765/v1",
    websocket_base_url="ws://localhost:8765/v1",
    api_key="not-needed",
)

with client.realtime.connect(model="local") as conn:
    conn.send({
        "type": "session.update",
        "session": {
            "type": "realtime",
            "instructions": "You are a helpful assistant.",
            "audio": {
                "input": {
                    "turn_detection": {
                        "type": "server_vad",
                        "interrupt_response": True,
                    }
                }
            },
        }
    })

    for event in conn:
        print(event.type)
```

The parts worth noticing are that `base_url` and `websocket_base_url` point to a local server and that `api_key` is essentially not needed. The instructions passed through `session.update`, server-side VAD turn detection, and interrupting a response mid-stream all follow the same schema as OpenAI Realtime. In other words, the application code barely changes, and only the backend moves from an external API to your own server. For teams worried about vendor lock-in, this interface compatibility is on its own the biggest practical value.

## Install and run

The path to standing up a server is just as brief. The default install covers the standard realtime path in one shot.

```bash
pip install speech-to-speech
```

The default configuration uses Parakeet TDT for STT, an OpenAI-compatible API for the LLM, and Qwen3-TTS for TTS. If you need a specific backend, install it with extras.

```bash
pip install "speech-to-speech[kokoro]"
pip install "speech-to-speech[faster-whisper]"
```

Running the server looks like this. The command launches an OpenAI Realtime compatible server over a local WebSocket.

```bash
export OPENAI_API_KEY=...
speech-to-speech
```

The interesting point here is that the LLM stage can run fully local. Below is an example that stands up a Gemma 4 class model with llama.cpp and has speech-to-speech point at that local endpoint.

```bash
llama-server -hf ggml-org/gemma-4-E4B-it-GGUF -np 2 -c 65536

speech-to-speech \
    --model_name "ggml-org/gemma-4-E4B-it-GGUF" \
    --responses_api_base_url "http://127.0.0.1:8080/v1" \
    --responses_api_api_key ""
```

On Apple Silicon Macs you can turn on optimized settings and attach an mlx model, and conversely, if local GPU is short, you can point the LLM backend at Hugging Face Inference Providers.

```bash
speech-to-speech \
    --local_mac_optimal_settings \
    --model_name "mlx-community/Qwen3-4B-Instruct-2507-bf16"
```

Being able to move the same pipeline across the spectrum, from fully local execution to delegated cloud inference, with a handful of flags is a virtue of the design.

## Modular swaps: STT, LLM, TTS backends

The reason this project reads as a reference architecture rather than a mere demo is that the backend of each stage can be swapped. In summary:

| Stage | Default backend | Alternatives |
|---|---|---|
| VAD | Silero VAD v5 | built-in only |
| STT | Parakeet TDT | Whisper, Faster Whisper, Paraformer |
| LLM | OpenAI-compatible API | Transformers, mlx-lm, vLLM, llama.cpp |
| TTS | Qwen3-TTS | Kokoro, Pocket TTS, ChatTTS, MMS |

There are also four run modes. The default, realtime, is the WebSocket that speaks the OpenAI Realtime protocol; local attaches directly to the microphone and speaker; and websocket and socket exchange raw PCM audio over WebSocket and TCP respectively. Language can be specified or left to auto-detection. Being able to combine STT accuracy, LLM quality and cost, and TTS timbre and latency to fit your own requirements is exactly the degree of freedom a closed API does not give you.

## Latency, and a real-world case

In a voice agent, latency matters as much as accuracy. People feel a conversation break when the reply is even a few hundred milliseconds late. The [realtime voice demo](https://huggingface.co/blog/cerebras-gemma4-voice-ai) that Hugging Face published together with Cerebras targets this latency problem head-on. The configuration uses Nvidia's Parakeet for STT, Google DeepMind's Gemma 4 running on Cerebras inference for the language model, and Alibaba's Qwen3-TTS for TTS. The goal is to drive down the LLM stage's response time with Cerebras' ultra-fast inference so that the conversation flows as naturally as talking to a person. That said, within what this article could confirm, no specific millisecond figures were published, so we hold off on a quantitative comparison.

There is production evidence too. This stack drives the Reachy Mini robots mentioned earlier, and Hugging Face states that more than 9,000 robots are already deployed in the field. The reason the project obsesses over latency is that in embedded settings, responsiveness is what makes an interaction "feel alive." We have separately covered the latency budget of voice agents from a GPU serving angle, so if you are thinking about how to allocate latency across each stage of the pipeline, we suggest reading [Voice agent latency budget and GPU serving](/tech-blog/en/llmops/voice-agent-latency-budget-gpu-serving/) alongside this.

## Implications for ThakiCloud's products

This pipeline meshes naturally with both of our products.

Through the ai-platform lens, the LLM stage of speech-to-speech ultimately just consumes an OpenAI-compatible endpoint, so you can drop ThakiCloud's vLLM serving straight into that slot. The STT and TTS models each become separate GPU-occupying workloads, and our strength is exactly in loading such heterogeneous inference workloads onto one cluster together, queuing GPUs with Kueue and isolating them across tenants. Voice traffic tends to accumulate cost by the second, so the unit-cost competitiveness of self-serving works especially strongly, and this open stack fits on-prem and sovereign requirements where data must not leave the premises. To customers for whom a closed voice API is a burden, we can offer the option of "running it on your own cluster through the same interface."

Through the Paxis lens, voice is a new input and output channel attached to an agent. Paxis is an Agent-Native Cloud control plane that runs on top of ai-platform and treats Skills, Tools, Policies, and Audit Logs as first-class resources, and the OpenAI Realtime compatible interface of speech-to-speech makes it easy to layer this voice channel onto existing agent orchestration. A flow where a spoken instruction becomes the agent's input and the result of a skill execution returns as speech can be composed while passing through policy gates and audit logs. Low-cost self-serving (ai-platform) creates the economics of voice agents, and on top of it the Agent-Native control plane (Paxis) handles voice as a channel safely.

## Closing

The message hugging-voice sends is clear. Realtime voice no longer has to lean solely on a few providers' closed APIs; when you need to, you can keep the interface as is and move only the backend onto your own infrastructure. This design, picking each stage from VAD through TTS and changing just one line in the client, sharply lowers the barrier for teams considering self-serving. If you want to see it for yourself, speak to it directly in the [demo Space](https://huggingface.co/spaces/HuggingFaceM4/hugging-voice), or start with `pip install speech-to-speech` from the [GitHub repository](https://github.com/huggingface/speech-to-speech).
