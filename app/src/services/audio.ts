// Audio recording and playback service
// Web Audio API based implementation for cross-platform compatibility

let mediaRecorder: MediaRecorder | null = null;
let audioChunks: Blob[] = [];
let audioContext: AudioContext | null = null;

// Request microphone permission
export const requestMicrophonePermission = async (): Promise<boolean> => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    stream.getTracks().forEach(track => track.stop());
    return true;
  } catch (error) {
    console.error('Microphone permission denied:', error);
    return false;
  }
};

// Check if microphone is available
export const isMicrophoneAvailable = async (): Promise<boolean> => {
  try {
    const devices = await navigator.mediaDevices.enumerateDevices();
    return devices.some(device => device.kind === 'audioinput');
  } catch {
    return false;
  }
};

// Start recording
export const startRecording = async (): Promise<void> => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ 
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        sampleRate: 16000,
      } 
    });
    
    audioChunks = [];
    
    // Determine the best supported MIME type
    const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
      ? 'audio/webm;codecs=opus'
      : MediaRecorder.isTypeSupported('audio/webm')
        ? 'audio/webm'
        : 'audio/mp4';
    
    mediaRecorder = new MediaRecorder(stream, { mimeType });
    
    mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        audioChunks.push(event.data);
      }
    };
    
    mediaRecorder.start(100); // Collect data every 100ms
  } catch (error) {
    console.error('Failed to start recording:', error);
    throw new Error('Failed to start recording. Please check microphone permissions.');
  }
};

// Stop recording and return audio blob
export const stopRecording = async (): Promise<Blob> => {
  return new Promise((resolve, reject) => {
    if (!mediaRecorder) {
      reject(new Error('No recording in progress'));
      return;
    }
    
    mediaRecorder.onstop = () => {
      const audioBlob = new Blob(audioChunks, { type: mediaRecorder?.mimeType || 'audio/webm' });
      
      // Stop all tracks
      mediaRecorder?.stream.getTracks().forEach(track => track.stop());
      mediaRecorder = null;
      audioChunks = [];
      
      resolve(audioBlob);
    };
    
    mediaRecorder.onerror = (event) => {
      reject(new Error('Recording error'));
    };
    
    mediaRecorder.stop();
  });
};

// Check if currently recording
export const isRecording = (): boolean => {
  return mediaRecorder?.state === 'recording';
};

// Play audio from URL or blob
export const playAudio = async (audioSource: string | Blob): Promise<void> => {
  return new Promise((resolve, reject) => {
    const audio = new Audio();
    
    if (typeof audioSource === 'string') {
      audio.src = audioSource;
    } else {
      audio.src = URL.createObjectURL(audioSource);
    }
    
    audio.onended = () => {
      if (typeof audioSource !== 'string') {
        URL.revokeObjectURL(audio.src);
      }
      resolve();
    };
    
    audio.onerror = () => {
      reject(new Error('Failed to play audio'));
    };
    
    audio.play().catch(reject);
  });
};

// Stop any playing audio
export const stopAudio = (): void => {
  // This is a simple implementation - for more complex cases,
  // we would track the audio element
};

// Convert blob to base64
export const blobToBase64 = (blob: Blob): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const base64 = reader.result as string;
      resolve(base64.split(',')[1]); // Remove data URL prefix
    };
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
};

// Create audio context for visualization
export const createAudioContext = (): AudioContext => {
  if (!audioContext) {
    audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
  }
  return audioContext;
};
