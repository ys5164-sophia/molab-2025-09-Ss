Project Overview
This project is an interactive emotion-driven audiovisual iOS application built with SwiftUI and AVFoundation. Users select a mood such as happy, calm, sad, energetic, anxious, focused, or bored, and the system generates a unique real-time visual waveform and a procedurally generated melody that reflects the selected emotional state. Instead of relying on pre-recorded music, the app synthesizes sound dynamically using randomized musical note pools. The waveform animation reacts directly to the real audio energy through RMS analysis, creating a tight coupling between sound and visual behavior.

Weekly Progress
In the first week, the project focused on building the basic SwiftUI interface and implementing the emotion selection system using an enum and visual parameter mapping. The second week real-time audio level analysis was added using an audio tap to extract RMS values and drive waveform amplitude. The final week concentrated on refining emotion differentiation, improving visual styles, adding smooth animated transitions between states, and stabilizing performance to ensure continuous, responsive interaction.

Challenges Encountered
One of the main challenges was synchronizing real-time audio generation with continuous visual updates without causing performance issues or dropped frames. Publishing audio energy values safely to the SwiftUI render pipeline required strict main-thread coordination to avoid concurrency crashes. Another major difficulty was preventing the waveform from disappearing due to invalid timeline updates or amplitude collapsing to zero when audio buffers were not active. Additionally, creating clearly distinct emotional visual identities required careful tuning of frequency, pulse speed, waveform style, and color palettes to avoid different emotions feeling visually repetitive.

Future Changes
Future development will explore more complex sound synthesis techniques such as layered harmonics, noise textures, and envelope shaping to enrich emotional depth. I also plan to introduce multi-layered visual elements such as particle systems, radial waveforms, or spatial depth effects to further separate emotional identities.
