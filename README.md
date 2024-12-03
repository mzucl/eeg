# EEG Preprocessing

TODO

## Features  

### EEG Data Overview  
The provided time-series EEG data underwent initial preprocessing, including:  
- Bandpass filtering (0.5 to 40 [Hz])  
- Segmentation into overlapping one-second epochs  
- Artifact removal  

This dataset includes information from 63 brain channels distributed across the scalp, recorded while subjects watched 45-second clips of sad and neutral movies.  

### Thesis-Specific Preprocessing  
Further preprocessing steps implemented in this thesis are summarized below. The input is a data structure containing time-series data for all trials across all channels for two conditions: 'neutral' and 'sad.' The output is the average power for each frequency band under both conditions.  

1. **Frequency Band Definition**:  
   - Delta (δ): 0.5–4 [Hz]  
   - Theta (θ): 4–8 [Hz]  
   - Alpha (α): 8–12 [Hz]  
   - Beta (β): 12–30 [Hz]  
   - Gamma (γ): 30–40 [Hz]  

2. **Power Spectrum Computation**:  
   Using the Fast Fourier Transform (FFT), the power spectrum is calculated across all channels, averaged over trials, for both 'neutral' and 'sad' conditions.  

3. **Average Power Calculation**:  
   Compute the average power within each frequency band (δ, θ, α, β, γ) for both conditions.  

4. **Logarithmic Scaling**:  
   Transform the computed power values using `10 * log10` scaling ([source](https://github.com/mzucl/eeg/)).  

5. **Channel Grouping (Optional)**:  
   To address the large number of features (63 channels × 5 frequency bands × 2 conditions = 630), a feature extraction method is proposed. Inspired by preprocessing approaches for MRI data, spatially close channels are grouped, and their power values are averaged before applying logarithmic scaling. This step ensures that the EEG data does not overpower other modalities when integrated into the GFA model.  

   > **Note**: The grouping strategy is detailed in the thesis and its corresponding figures.  

## Getting Started  

### Prerequisites  
- MATLAB (recommended version: R2020a or newer)  

### Setup  
1. Clone the repository:  
   ```bash  
   git clone https://github.com/mzucl/eeg-preprocessing.git  
