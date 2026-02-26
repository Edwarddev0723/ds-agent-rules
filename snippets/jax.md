# Snippet: JAX / Flax Best Practices

## Domain Context
Framework-specific rules for JAX-based ML development (Flax, Optax, Orbax).
JAX is functionally pure — embrace the paradigm, don't fight it.

## Core JAX Principles
- **Pure functions**: JAX transformations (jit, grad, vmap) require functions with no side effects
- **Explicit state**: model parameters are explicit pytrees, not hidden in objects
- **PRNG management**: always split keys explicitly — never reuse a PRNG key
  ```python
  key, subkey = jax.random.split(key)  # always split before use
  ```
- Prefer `jnp` over `np` for any computation that should be JIT-compilable

## Model Definition (Flax)
- Use `nn.Module` (Flax Linen) with `@nn.compact` for inline submodule definition
- Init params explicitly: `params = model.init(rng_key, dummy_input)`
- Separate model definition from training state — params, optimizer state, and model are distinct
- Use `TrainState` from Flax for clean state management:
  ```python
  state = train_state.TrainState.create(apply_fn=model.apply, params=params, tx=optimizer)
  ```

## JIT Compilation
- `@jax.jit` all training and evaluation functions — non-JIT code is significantly slower
- Mark non-static arguments that change shape as `donate_argnums` to save memory
- Use `static_argnums` for arguments that trigger recompilation (config flags, not data)
- Trace JIT compilation time: first call compiles, subsequent calls should be fast — profile both
- Avoid Python control flow inside JIT — use `jax.lax.cond` and `jax.lax.scan` instead

## Training Patterns
- Use `optax` for optimizers: chain transformations (e.g., `optax.chain(optax.clip_by_global_norm(1.0), optax.adam(lr))`)
- Gradient computation: `jax.grad` returns a function — apply it, don't call it in a loop
- `jax.value_and_grad` when you need both loss value and gradients (one forward pass)
- `jax.vmap` for batched operations — cleaner and faster than manual batch dimensions
- Scan for sequential operations: `jax.lax.scan` instead of Python for-loops

## Multi-Device Training
- `jax.pmap` for data parallelism across devices (legacy but stable)
- `jax.experimental.shard_map` or named sharding for modern multi-device (preferred for new code)
- Replicate params: `jax.device_put_replicated(params, jax.devices())`
- All-reduce gradients: `jax.lax.pmean(grads, axis_name='batch')`
- Check device count: `jax.device_count()` and `jax.local_device_count()` — log at startup

## Checkpointing
- Use Orbax for checkpointing: supports async saving, sharded checkpoints, and atomic operations
- Save complete state: params, optimizer state, step count, config
- Restore with shape checking: validate parameter shapes match the current model definition
- For large models: use sharded checkpointing to avoid OOM during save/load

## Debugging
- Disable JIT during debugging: `with jax.disable_jit():` or `JAX_DISABLE_JIT=1`
- NaN checking: `jax.config.update("jax_debug_nans", True)` during development
- Shape errors: use `jax.eval_shape` to check output shapes without computation
- Memory profiling: `jax.profiler.device_memory_profile()` for TPU/GPU memory analysis
- Print inside JIT: use `jax.debug.print()` not `print()` — regular print only runs at trace time

## Common Pitfalls
- Mutating arrays: JAX arrays are immutable — use `x.at[i].set(v)` not `x[i] = v`
- PRNG key reuse: produces correlated random numbers — always split before each use
- JIT recompilation: changing array shapes causes costly recompilation — pad to fixed shapes
- Forgetting `jax.tree_util` operations: params are nested dicts — use tree_map, not manual traversal
- NumPy/JAX mixing: `np.array` and `jnp.array` have different behaviors — be explicit about which you use
