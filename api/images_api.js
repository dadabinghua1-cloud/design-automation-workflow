/**
 * Reserved API integration point.
 *
 * Design Automation Workflow 1.2 may connect this file to an image generation
 * service. The current repository intentionally does not call image APIs.
 */
export async function createImageFromPrompt() {
  throw new Error("Images API is not connected in Workflow 1.1.");
}
