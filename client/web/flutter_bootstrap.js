{{flutter_js}}
{{flutter_build_config}}

// Create and append loading container
const loadingContainer = document.createElement('div');
loadingContainer.id = 'loading-container';
document.body.appendChild(loadingContainer);

// Add styles
const style = document.createElement('style');
style.textContent = `
  #loading-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 100vh;
    width: 100vw;
    background-color: #1a1a1a;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 9999;
  }

  .hourglass {
    width: 80px;
    height: 80px;
    border: 4px solid #fff;
    border-radius: 50%;
    position: relative;
    animation: rotate 2s linear infinite;
  }

  .hourglass::before,
  .hourglass::after {
    content: '';
    position: absolute;
    width: 40px;
    height: 40px;
    background: #ff69b4;
    border-radius: 50%;
    top: 50%;
    transform: translateY(-50%);
    animation: move 2s linear infinite;
  }

  .hourglass::before { left: -4px; }
  .hourglass::after { right: -4px; }

  @keyframes rotate {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  @keyframes move {
    0%, 100% { transform: translateY(-50%) scale(1); }
    50% { transform: translateY(-50%) scale(0.5); }
  }

  .loading-text {
    color: #fff;
    font-family: Arial, sans-serif;
    margin-top: 20px;
    font-size: 18px;
    letter-spacing: 2px;
    animation: pulse 1.5s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }
`;
document.head.appendChild(style);

// Add loading elements
const hourglass = document.createElement('div');
hourglass.className = 'hourglass';
loadingContainer.appendChild(hourglass);

const loadingText = document.createElement('div');
loadingText.className = 'loading-text';
loadingText.textContent = 'CHRONO QUEST';
loadingContainer.appendChild(loadingText);

// Handle Flutter initialization with minimum loading time
const MIN_LOADING_TIME = 2000;
const startTime = Date.now();

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    
    // Ensure minimum loading time
    const elapsed = Date.now() - startTime;
    const remaining = Math.max(0, MIN_LOADING_TIME - elapsed);
    
    setTimeout(() => {
      loadingContainer.remove();
    }, remaining);
  }
});