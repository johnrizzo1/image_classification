import torch

# We move our tensor to the GPU if available
if torch.backends.mps.is_available():
    print ("MPS is available. Using MPS")
    device = torch.device("mps")
elif torch.cuda.is_available():
    print ("CUDA is available. Using GPU")
    device = torch.device("cuda")
else:
    print ("No device not found. Using CPU")
    device = torch.device("cpu")

x = torch.ones(1, device=device)
print (x)