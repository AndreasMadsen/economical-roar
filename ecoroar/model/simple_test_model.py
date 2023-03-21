
from dataclasses import dataclass
from typing import Union

import tensorflow as tf

from ..types import TokenizedDict, EmbeddingDict, Model

_default_embedding = [
    [0, 1],  # BOS
    [0, 1],  # EOS
    [0, 0],  # PAD
    [1, 0],  # TOKEN
    [0, 1]   # MASK
]

_defalt_kernel = [
    [1, 0, 1],
    [0, 1, 1]
]

@dataclass
class SimpleOutput():
    logits: tf.Tensor

class SimpleTestConfig():
    model_type = 'simple test'

    def __init__(self, vocab_size=4) -> None:
        self.vocab_size = vocab_size

class SimpleTestModel(Model):
    def __init__(self,
                 embeddings_initializer=_default_embedding,
                 kernel_initializer=_defalt_kernel,
                 auto_initialize=True) -> None:
        super().__init__()
        embeddings_initializer = tf.convert_to_tensor(embeddings_initializer, dtype=tf.float32)
        kernel_initializer = tf.convert_to_tensor(kernel_initializer, dtype=tf.float32)

        self.config = SimpleTestConfig(vocab_size=embeddings_initializer.shape[0])

        self._embedding = tf.keras.layers.Embedding(
            input_dim=embeddings_initializer.shape[0],
            output_dim=embeddings_initializer.shape[1],
            embeddings_initializer=tf.keras.initializers.Constant(embeddings_initializer)
        )
        self._dense = tf.keras.layers.Dense(
            units=kernel_initializer.shape[1],
            use_bias=False,
            kernel_initializer=tf.keras.initializers.Constant(kernel_initializer)
        )

        if auto_initialize:
            self({
                'input_ids': tf.constant([[0, 0]], dtype=tf.dtypes.int32),
                'attention_mask': tf.constant([[1, 1]], dtype=tf.dtypes.int8),
            })

    def call(self, inputs: Union[TokenizedDict, EmbeddingDict], training=False) -> SimpleOutput:
        x = inputs

        if 'inputs_embeds' not in x:
            x = self.inputs_embeds(x, training=training)

        z = x['inputs_embeds']
        z = z * z
        z = tf.math.reduce_sum(z, axis=1)
        z = self._dense(z, training=training)
        return SimpleOutput(logits=z)

    def inputs_embeds(self, x: TokenizedDict, training=False) -> EmbeddingDict:
        z = self._embedding(x['input_ids'], training=training)
        return {
            'inputs_embeds': z,
            'attention_mask': x['attention_mask']
        }

    @property
    def embedding_matrix(self) -> tf.Variable:
        return self._embedding.embeddings