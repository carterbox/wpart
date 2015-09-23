projs = [12,14,15,18,19,20,21,22,23,24,25];

parfor i = 1:numel(projs)
    fixbandsfixbands(['/media/OCT14M/Reconstructions/recon_proj_' num2str(projs(i))],256,2560,2560)
end